using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System;
using System.IO;

namespace UnityEditor
{
    public class MeshPostConvert
    {
        public virtual void PostConvert(ref MeshData mesh)
        {
            
        }

        public virtual void OnGUI()
        {

        }
    }
    
    public class MeshPostConvert_Idol : MeshPostConvert
    {

        public override void PostConvert(ref MeshData mesh)
        {
            MeshData.VBuffer normalBuf;
            MeshData.VBuffer tangentBuf;

            bool hasNormal = mesh.Buffers.TryGetValue(ESemantic.Normal, out normalBuf);
            bool hasTangent = mesh.Buffers.TryGetValue(ESemantic.Tangent, out tangentBuf);
            
            if(hasNormal && hasTangent)
            { 
                int num = mesh.GetVertexCount();
                int n = 0;
                for (int i = 0; i < num; i++)
                {
                    var oldN = normalBuf.mData[i];
                    var oldT = tangentBuf.mData[i];
                    var l = oldN - oldT;
                    if(l.SqrMagnitude()>0.0001)
                    {
                        n++;
                    }
                }
                Debug.Log("num of diff between normal and tangent:" + n + " / " + num);
            }
        }
    }

    public class MeshPostConvert_HSMYJ : MeshPostConvert
    {
        private string mSkeletonDataFileName = "";
        private bool mUseSkeleton = false;
        private List<Vector4> mSkeletonData = new List<Vector4>();
        public override void PostConvert(ref MeshData mesh)
        {
            MeshData.VBuffer buff;
            if(mesh.Buffers.TryGetValue(ESemantic.Normal,out buff))
            {
                var normals = buff.mData;
                for(int i = 0;i< normals.Count;i++)
                { 
                    var normal = normals[i];
                    normals[i] = normal * 2 - new Vector4(1,1,1,0);
                }
            }

            int num = mesh.Trangles.Count / 3;
            for(int i = 0;i<num;i++)
            {
                int cache =mesh.Trangles[i * 3 + 1];
                mesh.Trangles[i * 3 + 1] = mesh.Trangles[i * 3 + 2];
                mesh.Trangles[i * 3 + 2] = cache;
            }
            if(mUseSkeleton)
                UseSkeletonData(ref mesh);
        }
        public override void OnGUI()
        {
            base.OnGUI();
            EditorGUILayout.BeginHorizontal();
            {
                EditorGUILayout.LabelField("Skeleton Data:", GUILayout.Width(100));
                mUseSkeleton = EditorGUILayout.Toggle(mUseSkeleton);
                if (mUseSkeleton)
                {
                    if (GUILayout.Button(mSkeletonDataFileName, EditorStyles.textField, GUILayout.Width(500)))
                    {
                        int id = mSkeletonDataFileName.LastIndexOf("/");
                        string path = mSkeletonDataFileName.Substring(0, id + 1);
                        path = EditorUtility.OpenFilePanel("select Skeleton Data file", path, "*");
                        if (!string.IsNullOrEmpty(path))
                        {
                            mSkeletonDataFileName = path;
                        }
                        LoadSkeletonData();

                    }
                }
                EditorGUILayout.LabelField(mSkeletonData.Count.ToString(), GUILayout.Width(50));
            }
            EditorGUILayout.EndHorizontal();
        }
        private void LoadSkeletonData()
        {
            mSkeletonData.Clear();
            StreamReader reader = null;
            try
            {
                if (string.IsNullOrEmpty(mSkeletonDataFileName))
                    return;
                reader = File.OpenText(mSkeletonDataFileName);
            }
            catch (Exception e)
            {
                reader.Close();
                Debug.LogError("打开文件失败：" + mSkeletonDataFileName + "\n" + e.Message);
                return;
            }

            string line = reader.ReadLine();
            char[] splits = { ' ', '\t' };
            while (line != null)
            {
                string[] elements = line.Split(splits);

                if (elements.Length == 4)
                {
                    Vector4 v = new Vector4();
                    for (int i = 0; i < 4; i++)
                    {
                        v[i] = float.Parse(elements[i]);
                    }
                    mSkeletonData.Add(v);
                }

                line = reader.ReadLine();
            }
            reader.Close();
        }
        private bool UseSkeletonData(ref MeshData mesh)
        {
            MeshData.VBuffer posBuf;
            MeshData.VBuffer normalBuf;
            MeshData.VBuffer tangentBuf;
            MeshData.VBuffer bnormalBuf;
            MeshData.VBuffer idBuf;
            MeshData.VBuffer weightBuf;

            if (!mesh.Buffers.TryGetValue(ESemantic.Position, out posBuf))
                return false;
            if (!mesh.Buffers.TryGetValue(ESemantic.Coord1, out idBuf))
                return false;
            if (!mesh.Buffers.TryGetValue(ESemantic.Coord2, out weightBuf))
                return false;

            bool hasNormal = mesh.Buffers.TryGetValue(ESemantic.Normal, out normalBuf);
            bool hasBnormal = mesh.Buffers.TryGetValue(ESemantic.BNormal, out bnormalBuf);
            bool hasTangent = mesh.Buffers.TryGetValue(ESemantic.Tangent, out tangentBuf);
            int num = mesh.GetVertexCount();
            for(int i = 0;i<num;i++)
            {
                Vector4 pos = posBuf.mData[i];
                Vector4 fid = idBuf.mData[i];
                int[] id = { Mathf.RoundToInt(fid.x), Mathf.RoundToInt(fid.y), Mathf.RoundToInt(fid.z), Mathf.RoundToInt(fid.w) };
                Vector4 wight = weightBuf.mData[i];
                var m0 = wight.x * mSkeletonData[id[0] * 3]+ wight.y * mSkeletonData[id[1] * 3]
                    + wight.z * mSkeletonData[id[2] * 3]+ wight.w * mSkeletonData[id[3] * 3];
                var m1 = wight.x * mSkeletonData[id[0] * 3 + 1] + wight.y * mSkeletonData[id[1] * 3 + 1]
                    + wight.z * mSkeletonData[id[2] * 3 + 1] + wight.w * mSkeletonData[id[3] * 3 + 1];
                var m2 = wight.x * mSkeletonData[id[0] * 3 + 2] + wight.y * mSkeletonData[id[1] * 3 + 2]
                    + wight.z * mSkeletonData[id[2] * 3 + 2] + wight.w * mSkeletonData[id[3] * 3 + 2];
                Vector4 newpos = Vector4.one;
                newpos.x = pos.x * m0.x + pos.y * m0.y + pos.z * m0.z + m0.w;
                newpos.y = pos.x * m1.x + pos.y * m1.y + pos.z * m1.z + m1.w;
                newpos.z = pos.x * m2.x + pos.y * m2.y + pos.z * m2.z + m2.w;
                posBuf.mData[i] = newpos;
                Vector4 oldV;
                Vector4 newV;
                if(hasNormal)
                {
                    oldV = normalBuf.mData[i];
                    newV = Vector4.zero;
                    newV.x = oldV.x * m0.x + oldV.y * m0.y + oldV.z * m0.z + m0.w;
                    newV.y = oldV.x * m1.x + oldV.y * m1.y + oldV.z * m1.z + m1.w;
                    newV.z = oldV.x * m2.x + oldV.y * m2.y + oldV.z * m2.z + m2.w;
                    normalBuf.mData[i] = newV;
                }
                if (hasTangent)
                {
                    oldV = tangentBuf.mData[i];
                    newV = Vector4.zero;
                    newV.x = oldV.x * m0.x + oldV.y * m0.y + oldV.z * m0.z + m0.w;
                    newV.y = oldV.x * m1.x + oldV.y * m1.y + oldV.z * m1.z + m1.w;
                    newV.z = oldV.x * m2.x + oldV.y * m2.y + oldV.z * m2.z + m2.w;
                    tangentBuf.mData[i] = newV;
                }
                if (hasBnormal)
                {
                    oldV = bnormalBuf.mData[i];
                    newV = Vector4.zero;
                    newV.x = oldV.x * m0.x + oldV.y * m0.y + oldV.z * m0.z + m0.w;
                    newV.y = oldV.x * m1.x + oldV.y * m1.y + oldV.z * m1.z + m1.w;
                    newV.z = oldV.x * m2.x + oldV.y * m2.y + oldV.z * m2.z + m2.w;
                    bnormalBuf.mData[i] = newV;
                }

            }
            mesh.Buffers.Remove(ESemantic.Coord1);
            mesh.Buffers.Remove(ESemantic.Coord2);

            return true;
        }
    }
}