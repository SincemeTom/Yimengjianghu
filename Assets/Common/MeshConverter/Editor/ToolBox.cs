using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class ToolBox : EditorWindow {
    enum ModuleType
    {
        ColorConvert,
        ObjectCache,
        Misc,
        Null
    }
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

    public static ToolBox Window = null;
    private ModuleType currentModule = ModuleType.ObjectCache;

    [MenuItem("GEffect/ToolBox")]
    static void AddWindow()
    {
        //if (Window != null)
        //    Window.Close();
        Window = EditorWindow.GetWindow<ToolBox>(false, "ToolBox");
        Window.minSize = new Vector2(350, 200);
        Window.Show();
    }
    int R = 0;
    int G = 0;
    int B = 0;
    List<Object> mObjectList = new  List<Object>();
    private void test()
    {
        float t = Mathf.Atan(0.22f);
        Debug.Log(t / 3.14 * 180);
    }
    private bool DrawModuleTitle(string title,ModuleType type)
    {
        EditorGUILayout.BeginHorizontal(EditorStyles.toolbar);
        {
            bool b = currentModule == type;
            string str = b ? "-    " : "+    ";
            if (GUILayout.Button(str + title, EditorStyles.label))
            {
                currentModule = b ? ModuleType.Null : type;
            }
        }
        EditorGUILayout.EndHorizontal();
        return currentModule == type;
    }
    private Vector2 scroll = Vector2.zero;
    public void OnGUI()
    {
        if (mStyles == null)
        {
            mStyles = new Styles();
        }
        scroll = EditorGUILayout.BeginScrollView(scroll,mStyles.mPreviewBox);
        {
            if (DrawModuleTitle("ColorConvert", ModuleType.ColorConvert))
            {
                DrawColorPass("R", ref R);
                DrawColorPass("G", ref G);
                DrawColorPass("B", ref B);
                EditorGUILayout.BeginHorizontal();
                {
                    if (GUILayout.Button("Copy Int", GUILayout.Width(80)))
                    {
                        GUIUtility.systemCopyBuffer = R + "," + G + "," + B;
                    }

                    float r = R / 255.0f;
                    float g = G / 255.0f;
                    float b = B / 255.0f;
                    if (GUILayout.Button("Copy Float", GUILayout.Width(80)))
                    {
                        GUIUtility.systemCopyBuffer = r + "," + g + "," + b;
                    }
                }
                EditorGUILayout.EndHorizontal();
                GUILayout.Space(30);
            }
            if (DrawModuleTitle("ObjectCache", ModuleType.ObjectCache))
            {
                DrawCache();
                GUILayout.Space(30);
            }
            if (DrawModuleTitle("Misc", ModuleType.Misc))
            {
                if (GUILayout.Button("Test", GUILayout.Width(40)))
                {
                    test();
                }
            }
        }
        EditorGUILayout.EndScrollView();
    }

    private void DrawCache()
    {
        EditorGUILayout.BeginHorizontal();
        {
            GUILayout.Space(24);
            var newobj = EditorGUILayout.ObjectField(null, typeof(Object), true, GUILayout.Width(150));
            if (newobj != null)
            {
                mObjectList.Add(newobj);
            }
        }
        EditorGUILayout.EndHorizontal();
        for (int i = 0, n = mObjectList.Count;i<n;i++)
        {
            GUILayout.Space(5);
            EditorGUILayout.BeginHorizontal();
            {
                var obj = mObjectList[i];

                if (GUILayout.Button("R", EditorStyles.toolbarButton, GUILayout.Width(20)))
                {
                    mObjectList.Remove(obj);
                    break;
                }
                var newobj = EditorGUILayout.ObjectField(obj, typeof(Object), true,GUILayout.Width(150));
                if (newobj != obj)
                {
                    if (newobj != null)
                    {
                        mObjectList[i] = newobj;
                    }
                    else
                    {
                        mObjectList.Remove(obj);
                        break;
                    }
                }
            }
            EditorGUILayout.EndHorizontal();
        }
    }

    private void DrawColorPass(string name, ref int value)
    {
        EditorGUILayout.BeginHorizontal();
        {
            EditorGUILayout.LabelField(name + ":", GUILayout.Width(20));
            value = EditorGUILayout.IntSlider(value, 0, 255);
            if(GUILayout.Button("C",GUILayout.Width (20)))
            {
                GUIUtility.systemCopyBuffer = value.ToString();
            }
            GUILayout.Space(20);
            float v = value / 255.0f;
            float v1 = EditorGUILayout.FloatField(v,GUILayout.Width(80));
            v1 = Mathf.Clamp01(v1);
            if (v1 != v)
            {
                value = Mathf.RoundToInt(v1 * 255);
            }
            if (GUILayout.Button("C", GUILayout.Width(20)))
            {
                GUIUtility.systemCopyBuffer = v1.ToString();
            }
        }
        EditorGUILayout.EndHorizontal();
    }
}
