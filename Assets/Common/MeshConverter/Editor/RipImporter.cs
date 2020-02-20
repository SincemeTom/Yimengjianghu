using UnityEngine;
using UnityEditor;
namespace UnityEngine {
    public class RipImporter : EditorWindow {
        class Styles {
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
            public Styles() {
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
        public float mMdlscaler = 1.0f;
        public bool mFlipUV = false;

        public System.Action<MeshData> onMeshDataPrepared;

        public RipData mRipData;

        Vector2 DataPanelScroll = new Vector2();
        int current = 0;
        void OnGUI() {
            if (null == mRipData)
                return;
            if (null == mStyles) {
                mStyles = new Styles();
            }
            int vertexNum = (int)mRipData.vertexCount;
            float height = this.position.height - 20;
            float width = 40;
            int viewItemNum = Mathf.FloorToInt(height / 18 - 1);

            current = (int)GUI.VerticalScrollbar(new Rect(0, 0, 20, height + 3), current, viewItemNum, 0, vertexNum);

            int end = Mathf.Min(current + viewItemNum, vertexNum);
            int start = Mathf.Max(0, end - viewItemNum);

            EditorGUILayout.BeginHorizontal();
            {
                GUILayout.Space(20);
                //draw id
                EditorGUILayout.BeginVertical(mStyles.mPreviewBox, GUILayout.Width(width),GUILayout.Height(height));
                {
                    EditorGUILayout.BeginHorizontal(mStyles.mOLTitle);
                    {
                        EditorGUILayout.LabelField(" id", EditorStyles.boldLabel, GUILayout.Width(width));
                    }
                    EditorGUILayout.EndHorizontal();
                    for (int i = start; i < end; ++i) {
                        EditorGUILayout.LabelField(i.ToString(), EditorStyles.boldLabel, GUILayout.Width(width));
                    }
                } 
                EditorGUILayout.EndVertical();
                GUILayout.Space(1);

                //data
                DataPanelScroll = EditorGUILayout.BeginScrollView(DataPanelScroll);
                EditorGUILayout.BeginHorizontal();
                {
                    for(int i = 0;i < mRipData.elements.Length; ++i) {
                        RipAttributeElement ele = mRipData.elements[i];                        
                        width = ele.dimension * 100;
                        EditorGUILayout.BeginVertical(mStyles.mPreviewBox, GUILayout.Width(width), GUILayout.Height(height));
                        {
                            EditorGUILayout.BeginHorizontal(mStyles.mOLTitle);
                            {         
                                ele.sematic = (ESemantic)EditorGUILayout.EnumPopup(ele.sematic, GUILayout.Width(width));
                            }
                            EditorGUILayout.EndHorizontal();
                            for(int j = start; j < end; ++j) {
                                EditorGUILayout.BeginHorizontal();
                                for(int k = 0; k < ele.dimension; ++k) {
                                    EditorGUILayout.LabelField(mRipData.vertexData[j * mRipData.dimensionPerVertex + k + ele.bytesOffset / 4].ToString(), GUILayout.Width(90));
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

            EditorGUILayout.BeginVertical();
            {
                GUILayout.Label(mRipData.GetInfo());
                mMdlscaler = EditorGUILayout.FloatField("Scale:", mMdlscaler);
                if (GUILayout.Button("确认导入")) {
                    onMeshDataPrepared(ConvertRipToMeshData(mRipData));
                    this.Close();
                }
            }
            EditorGUILayout.EndVertical();
            EditorGUILayout.EndHorizontal();        
        }

        private MeshData ConvertRipToMeshData(RipData ripData) {
            MeshData mesh = new MeshData(ripData.meshName);
            for(int i = 0; i < ripData.indexCount; ++i) {
                mesh.Trangles.Add((int)ripData.indexData[i]);
            }

            var buffers = mesh.Buffers;
            for(int i = 0; i < ripData.elements.Length; ++i) {
                RipAttributeElement ele = ripData.elements[i];
                if (ele.sematic == ESemantic.UnKnown)
                    continue;
                MeshData.VBuffer buff;
                if (!buffers.TryGetValue(ele.sematic,out buff)) {
                    buff = new MeshData.VBuffer();
                    buffers.Add(ele.sematic, buff);

                    buff.mDimension = (int)ele.dimension;

                    for(int j = 0; j < ripData.vertexCount; ++j) {
                        var data = new Vector4();
                        for (int k = 0; k < ele.dimension; ++k) {                           
                            float val = mRipData.vertexData[j * mRipData.dimensionPerVertex + k + ele.bytesOffset / 4];
                            if(ele.sematic == ESemantic.Position) {
                                //val *= mMdlscaler;
                            }
                            data[k] = val;
                        }
                        buff.mData.Add(data);
                    }
                }
            }
            return mesh;
        }
    }

}

