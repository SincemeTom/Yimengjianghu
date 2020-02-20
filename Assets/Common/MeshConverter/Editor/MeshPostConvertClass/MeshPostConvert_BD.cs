using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System;
using System.IO;

namespace UnityEditor
{
    public class MeshPostConvert_BD : MeshPostConvert
    {
        private string mSkeletonDataFileName = "";
        private bool mUseSkeleton = false;
        private List<Vector4> mSkeletonData = new List<Vector4>();
        public override void PostConvert(ref MeshData mesh)
        {


            //UV
            MeshData.VBuffer UVBuffer;
            if (mesh.Buffers.TryGetValue(ESemantic.Coord0, out UVBuffer))
            {
                var uvBuffers = UVBuffer.mData;
                for (int i = 0; i < uvBuffers.Count; i++)
                {
                    var uv = uvBuffers[i];
                    uvBuffers[i] = new Vector4(uv.x, 1.0f - uv.y, 0.0f, 0.0f);
                    //Debug.Log(UVBuffer.mData[i]);
                }
            }
            else
            {
                Debug.Log("No UV channel can be found");
                return;
            }
            //Normal ,BiNormal,Tangent
            MeshData.VBuffer NormalBuffer;
            bool hasNormal = mesh.Buffers.TryGetValue(ESemantic.Normal, out NormalBuffer);
            if (!hasNormal)
            {
                Debug.Log("No Normal channel can be found");
                return;
            }
            else
            {
                if (NormalBuffer.mDimension < 4)
                {
                    Debug.Log("No Normal.w  can be found");
                    return;
                }
                List<Vector4> normals = new List<Vector4>();
                List<Vector4> tangents = new List<Vector4>();
                List<Vector4> binormals = new List<Vector4>();
                for (int i = 0; i < NormalBuffer.mData.Count; i++)
                {
                    var normalData = NormalBuffer.mData[i];
                    Vector3 tan = new Vector3(0.0f, 0.0f, 0.0f),
                            bin = new Vector3(0.0f, 0.0f, 0.0f),
                            nor = new Vector3(0.0f, 0.0f, 0.0f);
                    DecodeTangentBinormal(normalData, ref tan, ref bin, ref nor);
                    normals.Add(new Vector4(nor.x, nor.y, nor.z, 0.0f));
                    tangents.Add(new Vector4(tan.x, tan.y, tan.z, 0.0f));
                    binormals.Add(new Vector4(bin.x, bin.y, bin.z, 0.0f));
                }
                NormalBuffer.mData = normals;
                NormalBuffer.mDimension = 3;

                MeshData.VBuffer TangentBuffer;
                bool hasTangent = mesh.Buffers.TryGetValue(ESemantic.Tangent, out TangentBuffer);

                if (!hasTangent)
                {
                    TangentBuffer = new MeshData.VBuffer();
                    mesh.Buffers.Add(ESemantic.Tangent, TangentBuffer);
                }
                TangentBuffer.mData = tangents;
                TangentBuffer.mDimension = 3;

                MeshData.VBuffer BiNormalBuffer;
                bool hasBiNormal = mesh.Buffers.TryGetValue(ESemantic.BNormal, out BiNormalBuffer);
                if (!hasBiNormal)
                {
                    BiNormalBuffer = new MeshData.VBuffer();
                    mesh.Buffers.Add(ESemantic.BNormal, BiNormalBuffer);
                }
                BiNormalBuffer.mData = binormals;
                BiNormalBuffer.mDimension = 3;
            }
            //Position
            MeshData.VBuffer posBuf;
            if (!mesh.Buffers.TryGetValue(ESemantic.Position, out posBuf))
                return;
            for (int i = 0; i < posBuf.mData.Count; i++)
            {
                Vector4 pos = posBuf.mData[i];
                pos.y += 2;
                pos.w = 1;
                posBuf.mData[i] = pos;
            }
            if (mUseSkeleton)
            {
                UseSkeletonData(ref mesh);
            }
            mesh.Buffers.Remove(ESemantic.Coord1);
            mesh.Buffers.Remove(ESemantic.Coord2);
            mesh.Buffers.Remove(ESemantic.Coord3);
            mesh.Buffers.Remove(ESemantic.Coord4);
        }

        static void SinCosBuild(float Angle, out float _sinout, out float _cosout)
        {
            _sinout = Mathf.Sin(Angle);
            _cosout = Mathf.Cos(Angle);
        }
        //
        static public void DecodeTangentBinormal(Vector4 Tangents, ref Vector3 Tangent, ref Vector3 BiNormal, ref Vector3 Normal)
        {
            Vector4 Angles = Tangents * Mathf.PI * 2.0f - new Vector4(Mathf.PI, Mathf.PI, Mathf.PI, Mathf.PI);
            float tLongSin = 0, tLongCos = 0, tLatSin = 0, tLatCos = 0,
                  bLongSin = 0, bLongCos = 0, bLatSin = 0, bLatCos = 0;

            SinCosBuild(Angles.x, out tLongSin, out tLongCos);
            SinCosBuild(Angles.y, out tLatSin, out tLatCos);
            SinCosBuild(Angles.z, out bLongSin, out bLongCos);
            SinCosBuild(Angles.w, out bLatSin, out bLatCos);
            Tangent = new Vector3(Mathf.Abs(tLatSin) * tLongCos, Mathf.Abs(tLatSin) * tLongSin, tLatCos);
            BiNormal = new Vector3(Mathf.Abs(bLatSin) * bLongCos, Mathf.Abs(bLatSin) * bLongSin, bLatCos);
            Normal = Vector3.Cross(Tangent, BiNormal);
            Vector3 tmp;
            if (Angles.w > 0.0)
            {
                tmp = new Vector3(Normal.x, Normal.y, Normal.z);
            }
            else
            {
                tmp = new Vector3(-Normal.x, -Normal.y, -Normal.z);
            }
            Normal = tmp;
        }

        private bool LoadSkeletonData()
        {
            mSkeletonData.Clear();
            StreamReader reader = null;
            mSkeletonDataFileName = "D:/Unity Projects/BlackDesert_Demo/Assets/BlackDesert/BD_SkeletonB.txt";
            try
            {
                if (string.IsNullOrEmpty(mSkeletonDataFileName))
                    return false;
                reader = File.OpenText(mSkeletonDataFileName);
            }
            catch (Exception e)
            {
                reader.Close();
                Debug.LogError("Open file ：" + mSkeletonDataFileName + "\n" + e.Message);
                return false;
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
            return true;
        }

        public bool UseSkeletonData(ref MeshData mesh)
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

            int num = posBuf.mData.Count;


            for (int i = 0; i < num; i++)
            {

                Matrix4x4 MSkin = Matrix4x4.zero;
                Vector4 pos = posBuf.mData[i];
                Vector4 blendIndex = idBuf.mData[i];
                Vector4 blendWeight = weightBuf.mData[i];
                

                int[] id = { Mathf.RoundToInt(blendIndex.x) * 3,
                Mathf.RoundToInt(blendIndex.y) * 3,
                Mathf.RoundToInt(blendIndex.z) * 3,
                Mathf.RoundToInt(blendIndex.w) * 3};

                
                Vector4 mSkinRow0 = GetData(id[0]) * blendWeight.x;

                Vector4 mSkinRow1 = GetData(id[0] + 1) * blendWeight.x;

                Vector4 mSkinRow2 = GetData(id[0] + 2) * blendWeight.x;
                Vector4 mSkinRow3 = new Vector4(0, 0, 0, blendWeight.x);


                mSkinRow0 += GetData(id[1]) * blendWeight.y;

                mSkinRow1 += GetData(id[1] + 1) * blendWeight.y;

                mSkinRow2 += GetData(id[1] + 2) * blendWeight.y;
                mSkinRow3.w += blendWeight.y;


                mSkinRow0 += GetData(id[2]) * blendWeight.z;

                mSkinRow1 += GetData(id[2] + 1) * blendWeight.z;

                mSkinRow2 += GetData(id[2] + 2) * blendWeight.z;
                mSkinRow3.w += blendWeight.z;
                

                mSkinRow0 += GetData(id[3] ) * blendWeight.w;

                mSkinRow1 += GetData(id[3] + 1) * blendWeight.w;
      
                mSkinRow2 += GetData(id[3] + 2) * blendWeight.w;
                mSkinRow3.w += blendWeight.w;


                MSkin.SetRow(0, mSkinRow0);
                MSkin.SetRow(1, mSkinRow1);
                MSkin.SetRow(2, mSkinRow2);
                MSkin.SetRow(3, mSkinRow3);
                
                //MSkin = MSkin.transpose;
                Vector4 newpos = Vector4.one;

                newpos = MSkin * pos;
                posBuf.mData[i] = newpos;


                Vector4 oldV;
                Vector4 newV;
                if (hasNormal)
                {
                    oldV = normalBuf.mData[i];
                    newV = Vector4.zero;
                    newV = MSkin * oldV;

                    normalBuf.mData[i] = newV;
                }
                if (hasTangent)
                {
                    oldV = tangentBuf.mData[i];
                    newV = Vector4.zero;
                    newV = MSkin * oldV;

                    tangentBuf.mData[i] = newV;
                }
                if (hasBnormal)
                {
                    oldV = bnormalBuf.mData[i];
                    newV = Vector4.zero;
                    newV = MSkin * oldV;

                    bnormalBuf.mData[i] = newV;
                }


            }
            
            Debug.Log("Vertex = " + posBuf.mData.Count);

            return true;
        }
        private Vector4 GetData(int index)
        {

            Vector4 ret = new Vector4();
            ret = mSkeletonData[index];
            return ret;
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
    }
}