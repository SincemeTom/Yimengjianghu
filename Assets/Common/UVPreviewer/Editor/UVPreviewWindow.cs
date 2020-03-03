using UnityEngine;
using UnityEditor;
using System;

namespace UniyEngine {
    public class UVPreviewWindow : EditorWindow {

        protected static UVPreviewWindow uvPreviewWindow;

        private int windowDefaultSize = 562; // 512 + (sideSpace*2)
        private int ySpace = 95;
        private int sideSpace = 25;
        private Rect uvPreviewRect;
        private Rect uvSpaceRect;

        private float scale = 1;

        private GameObject selectedObject = null;
        private Mesh m = null;
        private int[] tris;
        private Vector2[] uvs;
        private Rect screenCenter;
        private bool isStarted;

        private Texture2D fillTextureGray;
        private Texture2D fillTextureDark;

        private float xPanShift;
        private float yPanShift;

        private int gridStep = 16;

        private bool canDrawView;
        private bool mousePositionInsidePreview;

        private int selectedUV = 0;
        private string[] selectedUVStrings = new string[2];

        private Material lineMaterial;

        private Texture2D texture;

        [MenuItem("GEffect/UV Preview")]

        public static void Start() {

            uvPreviewWindow = (UVPreviewWindow)EditorWindow.GetWindow(typeof(UVPreviewWindow));
            uvPreviewWindow.titleContent = new GUIContent("UV Preview");
            uvPreviewWindow.autoRepaintOnSceneChange = true;
            uvPreviewWindow.minSize = new Vector2(512, 512);

        }


        void Update() {

            if (!isStarted) {

                screenCenter = new Rect(Screen.width / 2, Screen.height / 2, 1, 1);
                uvPreviewWindow.position = new Rect(screenCenter.x, screenCenter.y, windowDefaultSize, windowDefaultSize + ySpace);
                fillTextureGray = CreateFillTexture(1, 1, new Color(0, 0, 0, 0.1f));
                fillTextureDark = CreateFillTexture(1, 1, new Color(0, 0, 0, 0.5f));

                xPanShift = 0;
                yPanShift = 0;

                isStarted = true;

                selectedUVStrings[0] = "UV";
                selectedUVStrings[1] = "UV 2";

            }

        }

        void OnSelectionChange() {

        }

        void OnGUI() {

            Event e = Event.current;

            selectedObject = Selection.activeGameObject;

            if (selectedObject == null) {

                GUI.color = Color.gray;
                EditorGUILayout.HelpBox("请选择物件...", MessageType.Warning);
                canDrawView = false;

            } else {

                if (selectedObject.GetComponent<MeshFilter>() != null | selectedObject.GetComponent<SkinnedMeshRenderer>() != null) {

                    GUI.color = Color.green;
                    EditorGUILayout.HelpBox("选择的物件: " + selectedObject.name, MessageType.None);
                    GUI.color = Color.white;
                    canDrawView = true;

                    if (selectedObject.GetComponent<SkinnedMeshRenderer>() == null) {
                        m = selectedObject.GetComponent<MeshFilter>().sharedMesh;
                    } else {
                        m = selectedObject.GetComponent<SkinnedMeshRenderer>().sharedMesh;
                    }

                    if (m != null) {

                        GUILayout.BeginHorizontal();
                        if (m.uv2.Length > 0) {

                            selectedUV = GUILayout.Toolbar(selectedUV, selectedUVStrings);

                        } else {

                            selectedUV = 0;



                            GUILayout.BeginHorizontal();

                            EditorGUILayout.HelpBox("Mesh没有第二套UV", MessageType.None);

                            if (GUILayout.Button("生成第二套UV")) {
                                Unwrapping.GenerateSecondaryUVSet(m);
                                EditorApplication.Beep();
                                EditorUtility.DisplayDialog("完成", "第二套UV已经生成!", "确认");
                            }

                            GUILayout.EndHorizontal();

                        }

                        tris = m.triangles;

                        if (selectedUV == 0) {
                            uvs = m.uv;
                        } else {
                            uvs = m.uv2;
                        }
                    }

                } else {

                    GUI.color = Color.gray;
                    EditorGUILayout.HelpBox("物件必须有Mesh Filter/Skined Mesh Renderer组件", MessageType.Warning);
                    canDrawView = false;

                }

            }

            if (e.mousePosition.x > uvPreviewRect.x & e.mousePosition.x < uvPreviewRect.width + sideSpace & e.mousePosition.y > uvPreviewRect.y & e.mousePosition.y < uvPreviewRect.height + sideSpace + ySpace) {
                mousePositionInsidePreview = true;
            } else {
                mousePositionInsidePreview = false;
            }

            if (mousePositionInsidePreview) {

                if (e.type == EventType.MouseDrag) {
                    xPanShift += e.delta.x;
                    yPanShift += e.delta.y;
                }

                if (e.type == EventType.ScrollWheel) {
                    scale += -(e.delta.y * 0.02f);
                }

            }



            uvPreviewRect = new Rect(sideSpace, ySpace + sideSpace, uvPreviewWindow.position.width - (sideSpace * 2), uvPreviewWindow.position.height - ySpace - (sideSpace * 2));
            uvSpaceRect = new Rect(sideSpace + xPanShift, (int)(-1 * scale * windowDefaultSize + ySpace + sideSpace + yPanShift) + windowDefaultSize,
                            scale * windowDefaultSize, scale * windowDefaultSize);
            GUI.DrawTexture(new Rect(0, 0, uvPreviewWindow.position.width, ySpace), fillTextureGray);


            if (canDrawView) {

                GUI.DrawTexture(uvPreviewRect, fillTextureDark);

                //texture
                if (texture != null) {

                    GUI.BeginGroup(uvPreviewRect);
                    EditorGUI.DrawPreviewTexture(new Rect(uvSpaceRect.x - uvPreviewRect.x, uvSpaceRect.y - uvPreviewRect.y,
                                uvSpaceRect.width, uvSpaceRect.height), texture);
                    GUI.EndGroup();

                    //GUI.DrawTexture(uvSpaceRect, texture);
                }

                //GRID
                for (int i = 1; i < 4096; i += (int)(gridStep)) {

                    int x1h = (int)(uvPreviewRect.x - 1);
                    int x2h = (int)(uvPreviewRect.width + sideSpace);
                    int yh = i + (ySpace + sideSpace) - 1;

                    int y1v = ySpace + sideSpace;
                    int y2v = (int)(uvPreviewRect.height + ySpace + sideSpace);
                    int xv = i + sideSpace - 1;

                    if (yh < uvPreviewRect.height + ySpace + sideSpace) {
                        DrawLine(x1h, yh, x2h, yh, new Color(1, 1, 1, 0.15f));
                    }

                    if (xv < uvPreviewRect.width + sideSpace) {
                        DrawLine(xv, y1v, xv, y2v, new Color(1, 1, 1, 0.15f));
                    }

                }

                //UV
                for (int i = 0; i < tris.Length; i += 3) {


                    int line1x1 = (int)(uvs[tris[i]].x * (scale * windowDefaultSize) + sideSpace + xPanShift);
                    int line1y1 = (int)(-uvs[tris[i]].y * (scale * windowDefaultSize) + ySpace + sideSpace + yPanShift) + windowDefaultSize;
                    int line1x2 = (int)(uvs[tris[i + 1]].x * (scale * windowDefaultSize) + sideSpace + xPanShift);
                    int line1y2 = (int)(-uvs[tris[i + 1]].y * (scale * windowDefaultSize) + sideSpace + ySpace + yPanShift + windowDefaultSize);

                    int line2x1 = (int)(uvs[tris[i + 1]].x * (scale * windowDefaultSize) + sideSpace + xPanShift);
                    int line2y1 = (int)(-uvs[tris[i + 1]].y * (scale * windowDefaultSize) + ySpace + sideSpace + yPanShift) + windowDefaultSize;
                    int line2x2 = (int)(uvs[tris[i + 2]].x * (scale * windowDefaultSize) + sideSpace + xPanShift);
                    int line2y2 = (int)(-uvs[tris[i + 2]].y * (scale * windowDefaultSize) + sideSpace + ySpace + yPanShift) + windowDefaultSize;

                    int line3x1 = (int)(uvs[tris[i + 2]].x * (scale * windowDefaultSize) + sideSpace + xPanShift);
                    int line3y1 = (int)(-uvs[tris[i + 2]].y * (scale * windowDefaultSize) + ySpace + sideSpace + yPanShift) + windowDefaultSize;
                    int line3x2 = (int)(uvs[tris[i]].x * (scale * windowDefaultSize) + sideSpace + xPanShift);
                    int line3y2 = (int)(-uvs[tris[i]].y * (scale * windowDefaultSize) + sideSpace + ySpace + yPanShift) + windowDefaultSize;

                    Rect cropRect = new Rect(uvPreviewRect.x, uvPreviewRect.y, uvPreviewRect.width, uvPreviewRect.height);

                    DrawLine(line1x1, line1y1, line1x2, line1y2, new Color(0, 1, 1, 1), true, cropRect);
                    DrawLine(line2x1, line2y1, line2x2, line2y2, new Color(0, 1, 1, 1), true, cropRect);
                    DrawLine(line3x1, line3y1, line3x2, line3y2, new Color(0, 1, 1, 1), true, cropRect);


                }

                //uv clamp line
                {
                    int lbx = (int)(sideSpace + xPanShift);
                    int lby = (int)(ySpace + sideSpace + yPanShift) + windowDefaultSize;

                    int rbx = (int)(scale * windowDefaultSize + sideSpace + xPanShift);
                    int rby = (int)(ySpace + sideSpace + yPanShift) + windowDefaultSize;

                    int ltx = (int)(+sideSpace + xPanShift);
                    int lty = (int)(-scale * windowDefaultSize + ySpace + sideSpace + yPanShift) + windowDefaultSize;

                    int rtx = (int)(scale * windowDefaultSize + sideSpace + xPanShift);
                    int rty = (int)(-scale * windowDefaultSize + ySpace + sideSpace + yPanShift) + windowDefaultSize;

                    Rect cropRect = new Rect(uvPreviewRect.x, uvPreviewRect.y, uvPreviewRect.width, uvPreviewRect.height);

                    DrawLine(ltx, lty, rtx, rty, new Color(0, 1, 0, 1), true, cropRect);
                    DrawLine(ltx, lty, lbx, lby, new Color(0, 1, 0, 1), true, cropRect);
                    DrawLine(rtx, rty, rbx, rby, new Color(0, 1, 0, 1), true, cropRect);
                    DrawLine(lbx, lby, rbx, rby, new Color(0, 1, 0, 1), true, cropRect);

                }

                DrawLine(0, ySpace - 1, (int)uvPreviewWindow.position.width, ySpace - 1, Color.gray);

                DrawHollowRectangle((int)uvPreviewRect.x, (int)uvPreviewRect.y, (int)uvPreviewRect.width + sideSpace, (int)uvPreviewRect.height + ySpace + sideSpace, Color.gray);
                DrawHollowRectangle((int)uvPreviewRect.x, (int)uvPreviewRect.y, (int)uvPreviewRect.width + sideSpace, (int)uvPreviewRect.height + ySpace + sideSpace, Color.gray, 1);
                DrawHollowRectangle((int)uvPreviewRect.x, (int)uvPreviewRect.y, (int)uvPreviewRect.width + sideSpace, (int)uvPreviewRect.height + ySpace + sideSpace, Color.gray, 2);

                EditorGUIUtility.AddCursorRect(uvPreviewRect, MouseCursor.Pan);

                // if(GUILayout.Button("Save To PNG")){

                // 	UVSaveWindow uvSaveWindow = (UVSaveWindow)EditorWindow.GetWindow (typeof (UVSaveWindow));
                // 	uvSaveWindow.title = "Save to PNG";
                // 	uvSaveWindow.maxSize = new Vector2(256,125);
                // 	uvSaveWindow.minSize = new Vector2(256,124);
                // 	uvSaveWindow.uvsToRender = uvs;
                // 	uvSaveWindow.trianglesToRender = tris;

                // }


                texture = (Texture2D)EditorGUILayout.ObjectField("选择纹理贴图:", texture, typeof(Texture2D),true);

                GUILayout.EndHorizontal();

            }

            Repaint();

        }

        private Texture2D CreateFillTexture(int width, int height, Color fillColor) {

            Texture2D texture = new Texture2D(width, height);
            Color[] pixels = new Color[width * height];

            for (int i = 0; i < pixels.Length; i++) {
                pixels[i] = fillColor;
            }

            texture.SetPixels(pixels);
            texture.Apply();

            return texture;
        }



        private void DrawLine(int x1, int y1, int x2, int y2, Color lineColor, bool isCrop = false, Rect crop = default(Rect)) {


            if (!lineMaterial) {
                lineMaterial = new Material(Shader.Find("Internal/DrawLine"));
                lineMaterial.hideFlags = HideFlags.HideAndDontSave;
                lineMaterial.shader.hideFlags = HideFlags.HideAndDontSave;
            }

            lineMaterial.SetPass(0);

            if (isCrop) {

                // if(x1 < crop.x) x1 = (int)crop.x;
                // if(x1 > crop.width) x1 = (int)crop.width;
                // if(y1 < crop.y) y1 = (int)crop.y;
                // if(y1 > crop.height) y1 = (int)crop.height;

                // if(x2 < crop.x) x2 = (int)crop.x;
                // if(x2 > crop.width) x2 = (int)crop.width;
                // if(y2 < crop.y) y2 = (int)crop.y;
                // if(y2 > crop.height) y2 = (int)crop.height;
                CohenSutherlandClipLineDrawer.DrawLine(new Vector2(crop.x, crop.y), new Vector2(crop.x + crop.width, crop.y + crop.height),
                new Vector2(x1, y1), new Vector2(x2, y2), lineColor);

            } else {
                GL.Begin(GL.LINES);
                GL.Color(lineColor);
                GL.Vertex3(x1, y1, 0);
                GL.Vertex3(x2, y2, 0);
                GL.End();
            }


        }

        private void DrawHollowRectangle(int x, int y, int width, int height, Color rectangleColor, int expand = 0) {

            DrawLine(x - expand, y - expand, width + expand, y - expand, rectangleColor);
            DrawLine(x - expand, y - expand, x - expand, height + expand, rectangleColor);
            DrawLine(width + expand, y - expand, width + expand, height + expand, rectangleColor);
            DrawLine(x - expand, height + expand, width + expand, height + expand, rectangleColor);

        }


    }

    class CohenSutherlandClipLineDrawer {
        //区域码  
        private const int leftBitCode = 0x1;
        private const int rightBitCode = 0x2;
        private const int buttonBitCode = 0x4;
        private const int topBitCode = 0x8;

        static int inside(int code) {
            return Convert.ToInt32(code == 0);
        }   //判断点是否在裁剪区内  
        static int reject(int code1, int code2) {
            return Convert.ToInt32(code1 & code2);
        }    //判断能否完全排除一条线段  
        static int accept(int code1, int code2) {
            return Convert.ToInt32((code1 | code2) == 0);
        }   //判断能否完全接受一条线段  
        static void swapPT(ref Vector2 a, ref Vector2 b) {
            Vector2 t = a;
            a = b;
            b = t;
        }  //交换两个点  
        static void swapCode(ref int a, ref int b) {
            int t = a;
            a = b;
            b = t;
        }   //交换两个区域码  


        //确定一个点所在位置的区域码  
        static int encode(ref Vector2 p, ref Vector2 winMin, ref Vector2 winMax) {
            int code = 0x00;
            if (p.x < winMin.x)
                code |= leftBitCode;
            if (p.x > winMax.x)
                code |= rightBitCode;
            if (p.y < winMin.y)
                code |= buttonBitCode;
            if (p.y > winMax.y)
                code |= topBitCode;
            return code;
        }
        public static void DrawLine(Vector2 winMin, Vector2 winMax, Vector2 lineBegin, Vector2 lineEnd, Color lineColor) {
            int code1, code2;                    //保存两个端点的区域码  
            bool done = false, plotLine = false;    //判断裁剪是否结束和是否要绘制直线  
            float k = 0;              //斜率  
            while (!done) {
                code1 = encode(ref lineBegin, ref winMin, ref winMax);
                code2 = encode(ref lineEnd, ref winMin, ref winMax);
                if (accept(code1, code2) != 0)  {       //当前直线能完全绘制   
                    done = true;
                    plotLine = true;
                } else {
                    if (reject(code1, code2) != 0)     //当前直线能完全排除  
                        done = true;
                    else {
                        if (inside(code1) != 0) {   //若lineBegin端点在裁剪区内则交换两个端点使它在裁剪区外   
                            swapPT(ref lineBegin, ref lineEnd);
                            swapCode(ref code1, ref code2);
                        }
                        //计算斜率  
                        if (lineBegin.x != lineEnd.x)
                            k = (lineEnd.y - lineBegin.y) / (lineEnd.x - lineBegin.x);
                        //开始裁剪,以下与运算若结果为真，  
                        //则lineBegin在边界外，此时将lineBegin移向直线与该边界的交点  
                        if ((code1 & leftBitCode) != 0) {
                            lineBegin.y += (winMin.x - lineBegin.x) * k;
                            lineBegin.x = winMin.x;
                        } else if ((code1 & rightBitCode) != 0) {
                            lineBegin.y += (winMax.x - lineBegin.x) * k;
                            lineBegin.x = winMax.x;
                        } else if ((code1 & buttonBitCode) != 0) {
                            if (lineBegin.x != lineEnd.x)
                                lineBegin.x += (winMin.y - lineBegin.y) / k;
                            lineBegin.y = winMin.y;
                        } else if ((code1 & topBitCode) != 0) {
                            if (lineBegin.x != lineEnd.x)
                                lineBegin.x += (winMax.y - lineBegin.y) / k;
                            lineBegin.y = winMax.y;
                        }
                    }
                }
            }
            if (plotLine) {  //绘制裁剪好的直线  
                GL.Begin(GL.LINES);
                GL.Color(lineColor);
                GL.Vertex3(lineBegin.x, lineBegin.y, 0);
                GL.Vertex3(lineEnd.x, lineEnd.y, 0);
                GL.End();
            }
        }

    }
}

