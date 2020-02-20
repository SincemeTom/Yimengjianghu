using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using System;
using System.Text;

namespace UnityEditor
{

    public class MeshConverter : EditorWindow, ISerializationCallbackReceiver
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
        public static MeshConverter Window = null;
        public static MeshViewer MeshViewerWindow = null;
        public static RipImporter RipImporterWindow = null;
        public Dictionary<string, MeshData> MeshMap = new Dictionary<string, MeshData>();
        public Dictionary<string, ConvertStrategy> StrategyMap = new Dictionary<string, ConvertStrategy>();
        public Dictionary<string, MeshPostConvert> PostConvertMap = new Dictionary<string, MeshPostConvert>();
        public Dictionary<string, string> MeshPathMap = new Dictionary<string, string>();
        string GetConfigFilePath()
        {
            string path = Application.dataPath;
            int id = path.LastIndexOf("/");
            if (id != -1)
            {
                path = path.Substring(0, id);
            }
            return path + "/ProjectSettings/MeshConverter.cfg";
        }

        private static Styles mStyles;
        private ObjSerializer mObjReader = new ObjSerializer();
        private RipSerializer mRipReader = new RipSerializer();
        private string mOpenMeshPath = "";
        private string mSaveMeshPath = "";
        private string mNewMeshName = "";
        private string newStrategyName = "NewStrategyName";
        private List<string> MeshNames = new List<string>();
        private List<string> PostConvertNames = new List<string>();
        private Vector2 mMeshListScroll = new Vector2();
        private Vector2 mStrategyListScroll = new Vector2();
        [MenuItem("GEffect/MeshConverter")]
        static void AddWindow()
        {
            if (Window != null)
                Window.Close();
            Window = EditorWindow.GetWindow<MeshConverter>(false, "MeshEditor");
            Window.minSize = new Vector2(200, 200);
            Window.Show();
        }

        public void ViewMeshData(MeshData mesh)
        {
            MeshViewerWindow = EditorWindow.GetWindow<MeshViewer>(false, "Mesh Viewer");
            MeshViewerWindow.titleContent = new GUIContent(mesh.Name);
            MeshViewerWindow.minSize = new Vector2(450, 400);
            MeshViewerWindow.mMeshData = mesh;
            MeshViewerWindow.Show();
        }

        private void AddMeshData(string name, MeshData mesh,string filePath = null)
        {
            MeshMap[name] = mesh;
            string oldpath;
            MeshPathMap.TryGetValue(name, out oldpath);
            if(oldpath!=filePath)
                MeshPathMap[name] = filePath;
            RefreshMeshNameList();
        }
        
        private void RemoveMeshData(string key)
        {
            MeshPathMap.Remove(key);
            MeshMap.Remove(key);
            RefreshMeshNameList();
        }
        private void RefreshMeshNameList()
        {
            MeshNames.Clear();
            MeshNames.AddRange(MeshPathMap.Keys);
        }
        private void LoadConfigDataFromFile(string filePath = null)
        {
            if (string.IsNullOrEmpty(filePath))
            {
                filePath = EditorUtility.OpenFilePanel("Select localization data file", Application.streamingAssetsPath, "json");
            }
            if (File.Exists(filePath))
            {
                string dataAsJson = File.ReadAllText(filePath);
                InitByConfigData(dataAsJson);
            }
        }
        private void InitByConfigData(string str)
        {
            if (string.IsNullOrEmpty(str))
                return;
            
            var serConfigMap = JsonUtility.FromJson<SerializationMap<string, string>>(str);
            var configMap = serConfigMap.target;
            string jsonStr;
            if(configMap.TryGetValue("StrategyMap",out jsonStr))
            {
                var serStrategyMap = JsonUtility.FromJson<SerializationMap<string, ConvertStrategy>>(jsonStr);

                foreach (var pair in serStrategyMap.target)
                {
                    StrategyMap[pair.Key] = pair.Value;
                }
            }
            if (configMap.TryGetValue("MeshPathMap", out jsonStr))
            {
                var serMeshPathMap = JsonUtility.FromJson<SerializationMap<string, string>>(jsonStr);
                MeshPathMap = serMeshPathMap.target;
                RefreshMeshNameList();
            }
        }
        private string ToConfigData()
        {
            Dictionary<string, string> ConfigMap = new Dictionary<string, string>();

            SerializationMap<string, ConvertStrategy> serStrategyMap = new SerializationMap<string, ConvertStrategy>(StrategyMap);
            string StrategyMapStr = JsonUtility.ToJson(serStrategyMap);
            ConfigMap["StrategyMap"] = StrategyMapStr;

            SerializationMap<string, string> serMeshPathMap = new SerializationMap<string, string>(MeshPathMap);
            string MeshPathMapStr = JsonUtility.ToJson(serMeshPathMap);
            ConfigMap["MeshPathMap"] = MeshPathMapStr;
            
            SerializationMap<string, string> serConfigMap = new SerializationMap<string, string>(ConfigMap);
            string dataAsJson =JsonUtility.ToJson(serConfigMap);

            return dataAsJson;
        } 

        private void SaveConfigDataToFile(string filePath = null)
        {
            if (string.IsNullOrEmpty(filePath))
            {
                filePath = EditorUtility.SaveFilePanel("Save localization data file", Application.streamingAssetsPath, "", "json");
            }
            if (!string.IsNullOrEmpty(filePath))
            {
                string dataAsJson = ToConfigData();
                File.WriteAllText(filePath, dataAsJson);
            }
        }

        private void LoadMesh(string path)
        {
            if (File.Exists(path))
            {
                var mesh = mObjReader.Load(path);
                if (mesh != null && mesh.IsValid())
                {
                    AddMeshData(mesh.Name, mesh, path);
                }
            }
        }

        private void LoadRipFile(string path) {
            if (File.Exists(path)) {
                var rip = mRipReader.Load(path);
                if(null != rip) {
                    RipImporterWindow = EditorWindow.GetWindow<RipImporter>(false, "Rip Importer");
                    RipImporterWindow.titleContent = new GUIContent(rip.meshName);
                    RipImporterWindow.minSize = new Vector2(450, 400);
                    RipImporterWindow.mRipData = rip;
                    RipImporterWindow.onMeshDataPrepared += (MeshData mesh) => {
                        AddMeshData(mesh.Name, mesh, path);
                    };
                    RipImporterWindow.Show();
                }
            }
        }


        private void OnGUI()
        {
            if (mStyles == null)
            {
                mStyles = new Styles();
            }

            //toolbar
            EditorGUILayout.BeginHorizontal(mStyles.mPreviewBox, GUILayout.Height(22));
            {
                if (GUILayout.Button("加载obj文件", GUILayout.Width(80)))
                {
                    string path = EditorUtility.OpenFilePanel("select obj file", mOpenMeshPath, "obj");
                    if (!string.IsNullOrEmpty(path))
                    {
                        int id = path.LastIndexOf("/");
                        mOpenMeshPath = path.Substring(0, id + 1);
                        LoadMesh(path);
                    }

                }

                if (GUILayout.Button("加载rip文件", GUILayout.Width(80))) {
                    string path = EditorUtility.OpenFilePanel("select rip file", mOpenMeshPath, "rip");
                    if (!string.IsNullOrEmpty(path)) {
                        int id = path.LastIndexOf("/");
                        mOpenMeshPath = path.Substring(0, id + 1);
                        LoadRipFile(path);
                    }
                }
 
                GUILayout.FlexibleSpace();
                if (GUILayout.Button("策略另存为"))
                {
                    SaveConfigDataToFile();

                }
                GUILayout.Space(30);
                if (GUILayout.Button("打开策略"))
                {
                    LoadConfigDataFromFile();

                }
                GUILayout.Space(30);

                newStrategyName = EditorGUILayout.TextField(newStrategyName, GUILayout.Width(100));
                GUILayout.Space(5);
                if (GUILayout.Button("新建策略", GUILayout.Width(80)))
                {
                    if (!StrategyMap.ContainsKey(newStrategyName))
                    {
                        var strategy = new ConvertStrategy();
                        strategy.BufferInfos.Add(ESemantic.Position, new ConvertStrategy.BufferDataInfo(ESemantic.Position));
                        strategy.BufferInfos.Add(ESemantic.Normal, new ConvertStrategy.BufferDataInfo(ESemantic.Normal));
                        strategy.BufferInfos.Add(ESemantic.Coord0, new ConvertStrategy.BufferDataInfo(ESemantic.Coord0));
                        StrategyMap.Add(newStrategyName, strategy);
                    }
                }
            }
            EditorGUILayout.EndHorizontal();
            
            EditorGUILayout.BeginHorizontal();
            {
                GUILayout.Space(1);

                //draw mesh list
                EditorGUILayout.BeginVertical(mStyles.mPreviewBox, GUILayout.Width(155));
                {
                    GUILayout.Space(2);
                    mMeshListScroll = EditorGUILayout.BeginScrollView(mMeshListScroll);
                    foreach (var p in MeshPathMap)
                    {
                        if (string.IsNullOrEmpty(p.Value) && !MeshMap.ContainsKey(p.Key))
                        {
                            RemoveMeshData(p.Key);
                            break;
                        }
                        EditorGUILayout.BeginHorizontal();
                        GUILayout.Space(2);
                        if (GUILayout.Button(p.Key, EditorStyles.toolbarButton, GUILayout.Width(120)))
                        {
                            MeshData mesh;
                            if(!MeshMap.TryGetValue(p.Key,out mesh))
                            {
                                LoadMesh(p.Value);
                                if(!MeshMap.TryGetValue(p.Key, out mesh))
                                {
                                    Debug.LogWarning("无法打开文件：" + p.Value);
                                    RemoveMeshData(p.Key);
                                    break;
                                }
                            }
                            ViewMeshData(mesh);
                        }
                        if(GUILayout.Button("R",EditorStyles.toolbarButton,GUILayout.Width(30)))
                        {
                            RemoveMeshData(p.Key);
                            break;
                        }
                        EditorGUILayout.EndHorizontal();
                    }
                    EditorGUILayout.EndScrollView();
                }
                EditorGUILayout.EndVertical();
                GUILayout.Space(0);

                //draw strategy list
                EditorGUILayout.BeginVertical();
                {
                    mStrategyListScroll = EditorGUILayout.BeginScrollView(mStrategyListScroll);
                    foreach (var strategy in StrategyMap)
                    {

                        if (!DrawStrategy(strategy.Key, strategy.Value))
                            break;
                    }
                    EditorGUILayout.EndScrollView();
                }
                EditorGUILayout.EndVertical();
            }
            EditorGUILayout.EndHorizontal();
        }

        private bool DrawStrategy(string name, ConvertStrategy strategy)
        {
            EditorGUILayout.BeginVertical(mStyles.mPreviewBox);
            {
                EditorGUILayout.BeginHorizontal(GUILayout.Height(25));
                {
                    string newname = EditorGUILayout.DelayedTextField(name, EditorStyles.boldLabel, GUILayout.Width(200));
                    if(newname!=name)
                    {
                        if(!StrategyMap.ContainsKey(newname))
                        {
                            StrategyMap[newname] = strategy;
                            StrategyMap.Remove(name);
                            return false;
                        }
                    }
                    if(GUILayout.Button("删除策略",GUILayout.Width(80)))
                    {
                        StrategyMap.Remove(name);
                        return false;
                    }
                }
                EditorGUILayout.EndHorizontal();
                GUILayout.Space(2);

                //draw slots
                EditorGUILayout.BeginHorizontal();
                {

                    DrawSlot(ref strategy.SlotA, "SlotA:");
                    GUILayout.Space(10);
                    DrawSlot(ref strategy.SlotB, "SlotB:");
                    GUILayout.Space(10);
                    DrawSlot(ref strategy.SlotC, "SlotC:");
                    GUILayout.Space(10);
                    DrawSlot(ref strategy.SlotD, "SlotD:");
                }
                EditorGUILayout.EndHorizontal();
                GUILayout.Space(10);

                //draw buffer info
                foreach (var p in strategy.BufferInfos)
                {
                    if(!DrawBufferInfo(p.Key, p.Value))
                    {
                        strategy.BufferInfos.Remove(p.Key);
                        break;
                    }
                    GUILayout.Space(5);
                }
                GUILayout.Space(10);

                //draw strategy function buttons
                EditorGUILayout.BeginHorizontal(GUILayout.Height(25));
                {
                    GUILayout.Label("添加buffer：", GUILayout.Width(80));
                    var s = (ESemantic)EditorGUILayout.EnumPopup(ESemantic.UnKnown, GUILayout.Width(80));
                    if (s != ESemantic.UnKnown)
                    {
                        if (!strategy.BufferInfos.ContainsKey(s))
                        {
                            strategy.BufferInfos.Add(s, new ConvertStrategy.BufferDataInfo(s));
                        }
                    }

                    GUILayout.FlexibleSpace();


                    if (GUILayout.Button("检查", GUILayout.Width(50)))
                    {
                        int id = strategy.CheckValid();
                        Debug.Log(strategy.GetValidInfo(id));
                    }

                    if (GUILayout.Button("生成", GUILayout.Width(50)))
                    {

                        string path = EditorUtility.SaveFilePanel("save mesh file", mSaveMeshPath, mNewMeshName, "fbx");
                        if (!string.IsNullOrEmpty(path))
                        {
                            int id = path.LastIndexOf("/");
                            mNewMeshName = path.Substring(id + 1);
                            mSaveMeshPath = path.Substring(0, id + 1);

                            var newMesh = strategy.Convert(mNewMeshName);
                            if (newMesh != null)
                            {
                                MeshPostConvert postConvert;
                                if (PostConvertMap.TryGetValue(strategy.PostConvert, out postConvert))
                                {
                                    if (postConvert != null)
                                        postConvert.PostConvert(ref newMesh);
                                }

                                AddMeshData(newMesh.Name, newMesh);
                                FbxSerializer.WriteMeshFBX(newMesh, path);
                            }
                        }
                    }
                    GUILayout.Space(10);
                }
                EditorGUILayout.EndHorizontal();
                
                DrawPostConvert(strategy);
            }
            EditorGUILayout.EndVertical();
            // GUILayout.Space(5);
            return true;
        }

        private void DrawPostConvert(ConvertStrategy strategy)
        {
            EditorGUILayout.BeginHorizontal();
            {
                GUILayout.Label("Post Convert:", GUILayout.Width(90));
                int id = PostConvertNames.IndexOf(strategy.PostConvert);
                if (id <= 0)
                    id = 0;
                int newid = EditorGUILayout.Popup(id, PostConvertNames.ToArray(), GUILayout.Width(70));
                if (newid != id)
                {
                    strategy.PostConvert = PostConvertNames[newid];
                }
            }
            EditorGUILayout.EndHorizontal();
            MeshPostConvert postConvert;
            if (PostConvertMap.TryGetValue(strategy.PostConvert, out postConvert))
            {
                if (postConvert != null)
                {
                    postConvert.OnGUI();
                }
            }
        }

        private void DrawSlot(ref MeshData slot, string slotlabel)
        {
            int id = -1;
            if (slot != null)
            {
                id = MeshNames.IndexOf(slot.Name);
                GUILayout.Label(slotlabel, EditorStyles.boldLabel, GUILayout.Width(50));
            }
            else
            {
                GUILayout.Label(slotlabel, GUILayout.Width(50));
            }
            int newid = EditorGUILayout.Popup(id, MeshNames.ToArray());
            if (newid != id)
            {
                string n = MeshNames[newid];
                if(!MeshMap.ContainsKey(n) && MeshPathMap.ContainsKey(n))
                {
                    LoadMesh(MeshPathMap[n]);
                }
                slot = MeshMap[n];
            }
        }

        private bool DrawBufferInfo(ESemantic s, ConvertStrategy.BufferDataInfo info)
        {
            EditorGUILayout.BeginHorizontal();
            {
                if(GUILayout.Button("R",EditorStyles.toolbarButton,GUILayout.Width(30)))
                {
                    return false;
                }
                var slot = (ConvertStrategy.ESlot)EditorGUILayout.EnumPopup(ConvertStrategy.ESlot.None, GUILayout.Width(80));
                if (slot != ConvertStrategy.ESlot.None)
                {
                    info.X.Slot = slot;
                    info.Y.Slot = slot;
                    if ((int)s < (int)ESemantic.Coord0)
                        info.Z.Slot = slot;
                    if (s == ESemantic.Color)
                        info.W.Slot = slot;
                }
                var semantic = (ESemantic)EditorGUILayout.EnumPopup(ESemantic.UnKnown, GUILayout.Width(80));
                if (semantic != ESemantic.UnKnown)
                {
                    info.X.Semantic = semantic;
                    info.Y.Semantic = semantic;
                    info.Z.Semantic = semantic;
                    info.W.Semantic = semantic;
                }
                bool used = info.X.IsValid();
                if (!used)
                    GUILayout.Label(s.ToString() + ":", GUILayout.Width(80));
                else
                    GUILayout.Label(s.ToString() + ":", EditorStyles.boldLabel, GUILayout.Width(80));

                DrawPassDataInfo(info.X, "X", used);
                GUILayout.Space(20);
                used &= info.Y.IsValid();
                DrawPassDataInfo(info.Y, "Y", used);
                GUILayout.Space(20);
                used &= info.Z.IsValid();
                DrawPassDataInfo(info.Z, "Z", used);
                GUILayout.Space(20);
                used &= info.W.IsValid();
                DrawPassDataInfo(info.W, "W", used);
            }
            EditorGUILayout.EndHorizontal();
            return true;
        }
        private void DrawPassDataInfo(ConvertStrategy.PassDataInfo pass, string label, bool used = true)
        {
            if (used)
                GUILayout.Label(label, EditorStyles.boldLabel, GUILayout.Width(15));
            else
                GUILayout.Label(label, GUILayout.Width(15));
            pass.Slot = (ConvertStrategy.ESlot)EditorGUILayout.EnumPopup(pass.Slot, EditorStyles.toolbarPopup, GUILayout.Width(50));
            if (pass.Slot != ConvertStrategy.ESlot.None)
            {
                pass.Semantic = (ESemantic)EditorGUILayout.EnumPopup(pass.Semantic, EditorStyles.toolbarPopup, GUILayout.Width(70));
                pass.Pass = (ConvertStrategy.EPass)EditorGUILayout.EnumPopup(pass.Pass, EditorStyles.toolbarPopup, GUILayout.Width(30));
            }
            else
            {
                GUILayout.Space(100);
            }
        }
        
        public void OnBeforeSerialize()
        {
            SaveConfigDataToFile(GetConfigFilePath());
        }

        public void OnAfterDeserialize()
        {
            //内容转至OnEnable
        }

        private void OnEnable()
        {
            LoadConfigDataFromFile(GetConfigFilePath());

            PostConvertMap.Clear();
            PostConvertMap.Add("Nothing", null);
            PostConvertMap.Add("HSMYJ", new MeshPostConvert_HSMYJ());
            PostConvertMap.Add("Idol", new MeshPostConvert_Idol());
            PostConvertMap.Add("BD", new MeshPostConvert_BD());

            PostConvertNames.Clear();
            PostConvertNames.AddRange(PostConvertMap.Keys);
        }
        private void OnDestroy()
        {
            SaveConfigDataToFile(GetConfigFilePath());
        }
    }
}