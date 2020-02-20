using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;

public enum E_TextureChannel
{
    R,
    G,
    B,
    A
}

public class TextureInfo : System.IDisposable
{
    public int Width = 512;
    public int Height = 512;
    public FilterMode filterMode = FilterMode.Bilinear;
    public Texture Texture = null;
    public string Name = "";
    public string Path = "";
    public bool[] PreviewChannel = { true, true, true, true };
    public Vector4 GetChannalMask()
    {
        Vector4 v = Vector4.zero;
        v.x = PreviewChannel[0] ? 1 : 0;
        v.y = PreviewChannel[1] ? 1 : 0;
        v.z = PreviewChannel[2] ? 1 : 0;
        v.w = PreviewChannel[3] ? 1 : 0;
        return v;
    }

    public Vector4 GetChannelRef()
    {
        Vector4 v = Vector4.zero;
        if (!PreviewChannel[3])
            v.w = 1f;
        return v;
    }

    public TextureInfo(Texture texture)
    {
        Reset(texture);
    }
    public TextureInfo(int width, int height)
    {
        Width = width;
        Height = height;
        Texture = RenderTexture.GetTemporary(width, height);
    }

    public void Reset(Texture texture)
    {
        Dispose();
        Texture = texture;
        if (texture != null)
        {
            Width = texture.width;
            Height = texture.height;
            filterMode = texture.filterMode;
            Name = texture.name;
            Path = AssetDatabase.GetAssetPath(texture);
        }
    }
    public void Reset(int width, int height)
    {
        if(width!=Width || height != Height)
        {
            Dispose();
            Width = width;
            Height = height;
            Texture = RenderTexture.GetTemporary(width, height);
        }
    }

    public void Dispose()
    {
        var rt = Texture as RenderTexture;
        if(rt!=null)
        {
            RenderTexture.ReleaseTemporary(rt);
        }
        Texture = null;
    }
}

public class ChannelInfo
{
    public E_TextureChannel Channel;
    public TextureInfo Source;
    public bool Invert = false;
    public ChannelInfo(E_TextureChannel channel,Texture tex)
    {
        Channel = channel;
        Source = new TextureInfo(tex);
    }

    public Vector4 GetChannalMask()
    {
        Vector4 v = Vector4.zero;
        float iv = Invert ? -1f : 1f;
        switch(Channel)
        {
            case E_TextureChannel.R:
                v.x = iv;
                break;
            case E_TextureChannel.G:
                v.y = iv;
                break;
            case E_TextureChannel.B:
                v.z = iv;
                break;
            case E_TextureChannel.A:
                v.w = iv;
                break;
        }
        return v;
    }

    public float GetChannelRef()
    {
        return Invert ? 1f : 0f;
    }
}
[ExecuteInEditMode]
public class TextureChannelPacker : EditorWindow
{
    public class ConstString
    {
        public static readonly string _Tex = "_Tex";
        public static readonly string Mask = "Mask";
        public static readonly string Ref = "Ref";

        public static readonly string _SINGLE_CHANNEL = "_SINGLE_CHANNEL";

        public static readonly string _RTex = "_RTex";
        public static readonly string _GTex = "_GTex";
        public static readonly string _BTex = "_BTex";
        public static readonly string _ATex = "_ATex";
        public static readonly string Mask_R = "Mask_R";
        public static readonly string Mask_G = "Mask_G";
        public static readonly string Mask_B = "Mask_B";
        public static readonly string Mask_A = "Mask_A";
        public static readonly string Ref_RGBA = "Ref_RGBA";
    }
    public class MyGUIStyles
    {
        public GUIStyle ToolbarButton;
        public GUIStyle ToolbarButton_Disable;
        public MyGUIStyles()
        {
            ToolbarButton = new GUIStyle(EditorStyles.toolbarButton);
            ToolbarButton_Disable = new GUIStyle(EditorStyles.toolbarButton);
            ToolbarButton_Disable.normal.textColor = new Color(0.5f, 0.5f, 0.5f, 0.3f);
        }

    }
    public static TextureChannelPacker Window = null;
    public List<TextureInfo> SourceTextures = new List<TextureInfo>();
    public TextureInfo CanvasRT;
    public ChannelInfo R { get { return Channels[0]; } }
    public ChannelInfo G { get { return Channels[1]; } }
    public ChannelInfo B { get { return Channels[2]; } }
    public ChannelInfo A { get { return Channels[3]; } }

    private ChannelInfo[] Channels = {
        new ChannelInfo(E_TextureChannel.R, null),
        new ChannelInfo(E_TextureChannel.G, null),
        new ChannelInfo(E_TextureChannel.B, null),
        new ChannelInfo(E_TextureChannel.A, null)
    };

    private RenderTexture[] previewRT = new RenderTexture[4];
    private RenderTexture previewCanvas;

    private Shader mShader = null;
    private Material mMaterial = null;
    private MyGUIStyles mStyles;
    private string SaveName = "";
    void OnEnable()
    {
        CanvasRT = new TextureInfo(512, 512);
        mShader = Shader.Find("GEffect/TextureViewShader");
        if(mShader)
        {
            mMaterial = new Material(mShader);
        }
        for(int i = 0;i<previewRT.Length;i++)
        {
            previewRT[i] = RenderTexture.GetTemporary(256, 256);
        }
        previewCanvas = RenderTexture.GetTemporary(512, 512);
    }
    private void OnDisable()
    {
        for (int i = 0; i < previewRT.Length; i++)
        {
            RenderTexture.ReleaseTemporary(previewRT[i]);
        }
        RenderTexture.ReleaseTemporary(previewCanvas);
    }

    [MenuItem("GEffect/TextureChannelPacker")]
    static void AddWindow()
    {
        //if (Window != null)
        //    Window.Close();
        Window = EditorWindow.GetWindow<TextureChannelPacker>(false, "TextureChannelPacker");
        Window.minSize = new Vector2(350, 200);
        Window.Show();
    }
    private Vector2 scroll;
    private string[] ChannelNames = { "R", "G", "B", "A" };
    public void OnGUI()
    {
        if(mStyles == null)
            mStyles = new MyGUIStyles();
        bool forceRefresh = false;
        EditorGUILayout.BeginHorizontal(EditorStyles.toolbar, GUILayout.MaxWidth(2000));
        {
            GUILayout.Label("Open:", GUILayout.Width(50));
            var texture = (Texture2D)EditorGUILayout.ObjectField(null, typeof(Texture2D), true, GUILayout.Width(150));
            if (texture != null)
            {
                for (int i = 0; i < Channels.Length; i++)
                {
                    Channels[i].Channel = (E_TextureChannel)i;
                    Channels[i].Source.Reset(texture);
                }
                CanvasRT.Reset(texture.width, texture.height);
                SaveName = texture.name;
                forceRefresh = true;
            }
            GUILayout.FlexibleSpace();
            if (GUILayout.Button("Save as PNG", EditorStyles.toolbarButton))
            {
                Save(true);
            }
            GUILayout.Space(10);
            if (GUILayout.Button("Save as JPG",EditorStyles.toolbarButton))
            {
                Save(false);
            }
        }
        EditorGUILayout.EndHorizontal();
        GUILayout.Space(5);
        bool needrefresh = false;
        EditorGUILayout.BeginHorizontal();
        {
            GUILayout.FlexibleSpace();
            for (int i = 0; i < Channels.Length; i++)
            {
                bool b = DrawChannelInfo(180,ChannelNames[i], Channels[i], previewRT[i],forceRefresh);
                if (b)
                    needrefresh = true;
                if(i!=Channels.Length - 1)
                    GUILayout.Space(20);
            }
            GUILayout.FlexibleSpace();
        }
        EditorGUILayout.EndHorizontal();
        GUILayout.Space(20);

        //draw canvas button
        GUI.changed = false;

        EditorGUILayout.BeginHorizontal();
        {
            GUILayout.FlexibleSpace();
            EditorGUILayout.BeginVertical();
            {
                EditorGUILayout.BeginHorizontal();
                {
                    string s = CanvasRT.PreviewChannel[0] ? "R" : "R";
                    var style = CanvasRT.PreviewChannel[0] ? mStyles.ToolbarButton : mStyles.ToolbarButton_Disable;
                    if (GUILayout.Button(s, style, GUILayout.Width(20)))
                    {
                        CanvasRT.PreviewChannel[0] = !CanvasRT.PreviewChannel[0];
                    }
                    s = CanvasRT.PreviewChannel[1] ? "G" : "G";
                    style = CanvasRT.PreviewChannel[1] ? mStyles.ToolbarButton : mStyles.ToolbarButton_Disable;
                    if (GUILayout.Button(s, style, GUILayout.Width(20)))
                    {
                        CanvasRT.PreviewChannel[1] = !CanvasRT.PreviewChannel[1];
                    }
                    s = CanvasRT.PreviewChannel[2] ? "B" : "B";
                    style = CanvasRT.PreviewChannel[2] ? mStyles.ToolbarButton : mStyles.ToolbarButton_Disable;
                    if (GUILayout.Button(s, style, GUILayout.Width(20)))
                    {
                        CanvasRT.PreviewChannel[2] = !CanvasRT.PreviewChannel[2];
                    }
                    s = CanvasRT.PreviewChannel[3] ? "A" : "A";
                    style = CanvasRT.PreviewChannel[3] ? mStyles.ToolbarButton : mStyles.ToolbarButton_Disable;
                    if (GUILayout.Button(s, style, GUILayout.Width(20)))
                    {
                        CanvasRT.PreviewChannel[3] = !CanvasRT.PreviewChannel[3];
                    }
                }
                EditorGUILayout.EndHorizontal();
                EditorGUILayout.BeginHorizontal();
                {
                    var style = R.Invert ? mStyles.ToolbarButton : mStyles.ToolbarButton_Disable;
                    if (GUILayout.Button("I", style, GUILayout.Width(20)))
                    {
                        R.Invert = !R.Invert;
                    }
                    style = G.Invert ? mStyles.ToolbarButton : mStyles.ToolbarButton_Disable;
                    if (GUILayout.Button("I", style, GUILayout.Width(20)))
                    {
                        G.Invert = !G.Invert;
                    }
                    style = B.Invert ? mStyles.ToolbarButton : mStyles.ToolbarButton_Disable;
                    if (GUILayout.Button("I", style, GUILayout.Width(20)))
                    {
                        B.Invert = !B.Invert;
                    }
                    style = A.Invert ? mStyles.ToolbarButton : mStyles.ToolbarButton_Disable;
                    if (GUILayout.Button("I", style, GUILayout.Width(20)))
                    {
                        A.Invert = !A.Invert;
                    }
                }
                EditorGUILayout.EndHorizontal();
            }
            EditorGUILayout.EndVertical();
            GUILayout.FlexibleSpace();
            EditorGUILayout.BeginVertical();
            {
                int width = CanvasRT.Width;
                int height = CanvasRT.Height;
                EditorGUILayout.BeginHorizontal();
                {
                    EditorGUILayout.LabelField("Width:", GUILayout.Width(50));
                    width = EditorGUILayout.DelayedIntField(CanvasRT.Width, GUILayout.Width(50));
                    GUILayout.Space(30);
                    EditorGUILayout.LabelField("Height:", GUILayout.Width(50));
                    height = EditorGUILayout.DelayedIntField(CanvasRT.Height, GUILayout.Width(50));
                }
                EditorGUILayout.EndHorizontal();
                EditorGUILayout.BeginHorizontal();
                {
                    if (GUILayout.Button("128", EditorStyles.toolbarButton, GUILayout.Width(50)))
                    {
                        width = height = 128;
                    }
                    if (GUILayout.Button("256", EditorStyles.toolbarButton, GUILayout.Width(50)))
                    {
                        width = height = 256;
                    }
                    if (GUILayout.Button("512", EditorStyles.toolbarButton, GUILayout.Width(50)))
                    {
                        width = height = 512;
                    }
                    if (GUILayout.Button("1024", EditorStyles.toolbarButton, GUILayout.Width(50)))
                    {
                        width = height = 1024;
                    }
                    if (GUILayout.Button("2048", EditorStyles.toolbarButton, GUILayout.Width(50)))
                    {
                        width = height = 2048;
                    }
                }
                EditorGUILayout.EndHorizontal();
                if (width != CanvasRT.Width || height != CanvasRT.Height)
                {
                    CanvasRT.Reset(width, height);
                }
            }
            EditorGUILayout.EndVertical();

            GUILayout.FlexibleSpace();
        }
        EditorGUILayout.EndHorizontal();

        //draw canvas
        GUILayout.BeginHorizontal();
        {
            GUILayout.FlexibleSpace();
            var rect = EditorGUILayout.GetControlRect(GUILayout.MaxWidth(CanvasRT.Width), GUILayout.MaxHeight(CanvasRT.Height), GUILayout.ExpandHeight(false));
            float w = rect.width;
            float h = rect.height;
            rect.height = Mathf.Min(rect.height, CanvasRT.Height * rect.width / CanvasRT.Width);
            rect.width = Mathf.Min(rect.width, CanvasRT.Width * rect.height / CanvasRT.Height);
            rect.x += (w - rect.width) * 0.5f;
            rect.y += (h - rect.height) * 0.5f;
            EditorGUI.DrawTextureTransparent(rect, previewCanvas);
            GUILayout.FlexibleSpace();
        }
        GUILayout.EndHorizontal();
        if (GUI.changed || needrefresh)
        {
            DrawCombine();
            DrawPreview(CanvasRT, previewCanvas);
        }
    }

    private bool DrawChannelInfo(float width,string C, ChannelInfo info, RenderTexture rt, bool forceRefresh)
    {
        EditorGUILayout.BeginVertical(GUILayout.MaxWidth(width));
        {
            GUI.changed = false;
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField(C + ":", GUILayout.Width(30));
            info.Channel = (E_TextureChannel)EditorGUILayout.EnumPopup(info.Channel, EditorStyles.toolbarDropDown, GUILayout.Width(width-33));
            EditorGUILayout.EndHorizontal();
            var texture = (Texture2D)EditorGUILayout.ObjectField(info.Source.Texture, typeof(Texture2D), true, GUILayout.Width(width));
            if (texture != info.Source.Texture)
            {
                info.Source.Reset(texture);
            }
            var rect = EditorGUILayout.GetControlRect(GUILayout.Width(width), GUILayout.Height(width));
            EditorGUI.DrawTextureTransparent(rect, rt);

            EditorGUILayout.BeginHorizontal();
            {
                string s = info.Source.PreviewChannel[0] ? "R" : "R";
                var style = info.Source.PreviewChannel[0] ? mStyles.ToolbarButton : mStyles.ToolbarButton_Disable;
                if (GUILayout.Button(s, style, GUILayout.Width(20)))
                {
                    info.Source.PreviewChannel[0] = !info.Source.PreviewChannel[0];
                }
                s = info.Source.PreviewChannel[1] ? "G" : "G";
                style = info.Source.PreviewChannel[1] ? mStyles.ToolbarButton : mStyles.ToolbarButton_Disable;
                if (GUILayout.Button(s, style, GUILayout.Width(20)))
                {
                    info.Source.PreviewChannel[1] = !info.Source.PreviewChannel[1];
                }
                s = info.Source.PreviewChannel[2] ? "B" : "B";
                style = info.Source.PreviewChannel[2] ? mStyles.ToolbarButton : mStyles.ToolbarButton_Disable;
                if (GUILayout.Button(s, style, GUILayout.Width(20)))
                {
                    info.Source.PreviewChannel[2] = !info.Source.PreviewChannel[2];
                }
                s = info.Source.PreviewChannel[3] ? "A" : "A";
                style = info.Source.PreviewChannel[3] ? mStyles.ToolbarButton : mStyles.ToolbarButton_Disable;
                if (GUILayout.Button(s, style, GUILayout.Width(20)))
                {
                    info.Source.PreviewChannel[3] = !info.Source.PreviewChannel[3];
                }
            }
            EditorGUILayout.EndHorizontal();
            if (GUI.changed || forceRefresh)
            {
                DrawPreview(info.Source, rt);
            }
        }
        EditorGUILayout.EndVertical();
        return GUI.changed || forceRefresh;
    }

    private void DrawPreview(TextureInfo info, RenderTexture rt)
    {
        if (rt != null && mMaterial != null)
        {
            mMaterial.SetTexture(ConstString._Tex, info.Texture);
            var mask = info.GetChannalMask();
            mMaterial.SetVector(ConstString.Mask, mask);
            mMaterial.SetVector(ConstString.Ref, info.GetChannelRef());
            if (Vector4.Dot( mask,Vector4.one) > 1.0f)
                mMaterial.DisableKeyword(ConstString._SINGLE_CHANNEL);
            else
                mMaterial.EnableKeyword(ConstString._SINGLE_CHANNEL);

            Graphics.Blit(null, rt, mMaterial, 1);
        }
    }
    private void DrawCombine()
    {
        var rt = CanvasRT.Texture as RenderTexture;
        if (rt != null && mMaterial != null)
        {
            mMaterial.SetTexture(ConstString._RTex, R.Source.Texture);
            mMaterial.SetTexture(ConstString._GTex, G.Source.Texture);
            mMaterial.SetTexture(ConstString._BTex, B.Source.Texture);
            mMaterial.SetTexture(ConstString._ATex, A.Source.Texture);
            mMaterial.SetVector(ConstString.Mask_R, R.GetChannalMask());
            mMaterial.SetVector(ConstString.Mask_G, G.GetChannalMask());
            mMaterial.SetVector(ConstString.Mask_B, B.GetChannalMask());
            mMaterial.SetVector(ConstString.Mask_A, A.GetChannalMask());
            Vector4 Ref = new Vector4(R.GetChannelRef(), G.GetChannelRef(), B.GetChannelRef(), A.GetChannelRef());
            mMaterial.SetVector(ConstString.Ref_RGBA, Ref);

            Graphics.Blit(null, rt, mMaterial, 0);
        }
    }

    private void Save(bool isPng,string filePath = null)
    {
        //bool isPng = CanvasRT.PreviewChannel[3];
        if (string.IsNullOrEmpty(filePath))
        {
            string ext = isPng ? "png" : "jpg";
            filePath = EditorUtility.SaveFilePanel("Save localization data file", Application.streamingAssetsPath, SaveName, ext);
        }
        if (string.IsNullOrEmpty(filePath))
        {
            return;
        }
        int id = filePath.LastIndexOf("/");
        if(id!=-1)
            SaveName = filePath.Substring(id+1);
        id = SaveName.LastIndexOf(".");
        if (id != -1)
            SaveName = SaveName.Substring(0, id);
        var rt = CanvasRT.Texture as RenderTexture;
        if (rt == null)
            return;
        RenderTexture prev = RenderTexture.active;
        RenderTexture.active = rt;
        Texture2D png = new Texture2D(rt.width, rt.height, TextureFormat.ARGB32, false);
        png.ReadPixels(new Rect(0, 0, rt.width, rt.height), 0, 0);
        byte[] bytes;
        if (isPng)
            bytes = png.EncodeToPNG();
        else
            bytes = png.EncodeToJPG(100);
        FileStream file = File.Open(filePath, FileMode.Create);
        BinaryWriter writer = new BinaryWriter(file);
        writer.Write(bytes);
        file.Close();
        Texture2D.DestroyImmediate(png);
        png = null;
        RenderTexture.active = prev;
        AssetDatabase.Refresh();
    }

}
