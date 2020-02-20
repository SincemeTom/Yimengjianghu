using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class MeshViewer : EditorWindow
{
    class Styles
    {
        //	public GUIContent m_WarningContent = new GUIContent(string.Empty, EditorGUIUtility.LoadRequired("Builtin Skins/Icons/console.warnicon.sml.png") as Texture2D);
        public GUIStyle mPreviewBox = new GUIStyle("OL Box");
        public GUIStyle mPreviewTitle = new GUIStyle("OL Title");
        public GUIStyle mPreviewTitle1 = new GUIStyle("OL Box");
        public GUIStyle mLoweredBox = new GUIStyle("TextField");
        public GUIStyle mHelpBox = new GUIStyle("helpbox");
        public GUIStyle mMiniLable = new GUIStyle("MiniLabel");
        public GUIStyle mSelected = new GUIStyle("LODSliderRangeSelected");
        public GUIStyle mOLTitle = new GUIStyle("OL Title");
        public GUIStyle mHLine = new GUIStyle();
        public GUIStyle mVLine = new GUIStyle();
        public Styles()
        {
            mLoweredBox.padding = new RectOffset(1, 1, 1, 1);
            mPreviewTitle1.fixedHeight = 0;
            mPreviewTitle1.fontStyle = FontStyle.Bold;
            mPreviewTitle1.alignment = TextAnchor.MiddleLeft;

            mHLine.fixedHeight = 1f;
            mHLine.margin = new RectOffset(0, 0, 0, 0);
            mVLine.fixedWidth = 1f;
            mVLine.stretchHeight = true;
            mVLine.stretchWidth = false;
        }
    }
    private static Styles mStyles;

    public MeshData mMeshData;

    Vector2 DataPanelScroll = new Vector2();
    int current = 0;
    public void OnGUI()
    {
        if (mMeshData == null)
            return;
        if (mStyles == null)
        {
            mStyles = new Styles();
        }
        int vertexNum = mMeshData.GetVertexCount();
        float height = this.position.height - 20 ;
        float width = 40;
        int viewItemNum = Mathf.FloorToInt(height / 18 - 1);

        //id scroll bar
        current = (int)GUI.VerticalScrollbar(new Rect(0, 0, 20, height+3), current, viewItemNum, 0, vertexNum);

        int end = Mathf.Min(current + viewItemNum, vertexNum);
        int start = Mathf.Max(0, end - viewItemNum);
        EditorGUILayout.BeginHorizontal();
        {
            GUILayout.Space(20);
            //draw id
            EditorGUILayout.BeginVertical(mStyles.mPreviewBox, GUILayout.Width(width), GUILayout.Height(height));
            {
                EditorGUILayout.BeginHorizontal(mStyles.mOLTitle);
                {
                    EditorGUILayout.LabelField(" id", EditorStyles.boldLabel, GUILayout.Width(width));
                }
                EditorGUILayout.EndHorizontal();
                for (int i = start; i < end; i++)
                {
                    EditorGUILayout.LabelField(i.ToString(), EditorStyles.boldLabel, GUILayout.Width(width));
                }
            }
            EditorGUILayout.EndVertical();
            GUILayout.Space(1);

            DataPanelScroll = EditorGUILayout.BeginScrollView(DataPanelScroll);
            EditorGUILayout.BeginHorizontal();
            {
                foreach (var pair in mMeshData.Buffers)
                {
                    ESemantic s = pair.Key;
                    MeshData.VBuffer buff = pair.Value;

                    width = buff.mDimension * 100;
                    EditorGUILayout.BeginVertical(mStyles.mPreviewBox, GUILayout.Width(width), GUILayout.Height(height));
                    {
                        EditorGUILayout.BeginHorizontal(mStyles.mOLTitle);
                        {
                            EditorGUILayout.LabelField(" " + s.ToString(), EditorStyles.boldLabel, GUILayout.Width(width));
                        }
                        EditorGUILayout.EndHorizontal();
                        for (int i = start; i < end; i++)
                        {
                            EditorGUILayout.BeginHorizontal();
                            for (int j = 0; j < buff.mDimension; j++)
                            {
                                EditorGUILayout.LabelField(buff.mData[i][j].ToString(), GUILayout.Width(90));
                            }
                            EditorGUILayout.EndHorizontal();
                        }
                    }
                    EditorGUILayout.EndVertical();
                }

            }
            EditorGUILayout.EndHorizontal();
            EditorGUILayout.EndScrollView();
        }
        GUILayout.Label(mMeshData.GetInfo());
        EditorGUILayout.EndHorizontal();
    }
}
