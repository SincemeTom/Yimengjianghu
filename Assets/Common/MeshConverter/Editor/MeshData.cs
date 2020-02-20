using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Text;


namespace UnityEngine
{
    [System.Serializable]
    public enum ESemantic
    {
        UnKnown,
        Position,
        Color,
        Normal,
        Tangent,
        BNormal,
        Coord0,
        Coord1,
        Coord2,
        Coord3,
        Coord4
    }
    public class MeshData
    {
        public class VBuffer
        {
            public List<Vector4> mData = new List<Vector4>();
            public int mDimension = 0;
        };
        public string Name;
        public Dictionary<ESemantic, VBuffer> Buffers = new Dictionary<ESemantic, VBuffer>();
        public List<int> Trangles = new List<int>();

        public MeshData(string name)
        {
            Name = name;

        }

        public int GetVertexCount()
        {
            if (Buffers.Count == 0)
                return 0;
            var enu = Buffers.GetEnumerator();
            enu.MoveNext();
            int num = enu.Current.Value.mData.Count;
            return num;
        }
        public int GetIndexCount()
        {
            return Trangles.Count;
        }
        public bool IsValid()
        {
            bool b = Trangles.Count > 0 && Buffers.Count > 0;
            if (!b)
                return false;
            var enu = Buffers.GetEnumerator();
            enu.MoveNext();
            int num = enu.Current.Value.mData.Count;
            while(enu.MoveNext())
            {
                if (num != enu.Current.Value.mData.Count)
                    return false;
            }
            return true;
        }

        public void AddData(ESemantic s, Vector4 data, int dimension = 4)
        {
            VBuffer buff;
            if (!Buffers.TryGetValue(s, out buff))
            {
                buff = new VBuffer();
                Buffers.Add(s, buff);
            }
            buff.mData.Add(data);
            buff.mDimension = Mathf.Max(buff.mDimension, dimension);
        }
        public void AddDataRange(ESemantic s, IEnumerable<Vector4> datas,int dimension = 4)
        {
            VBuffer buff;
            if (!Buffers.TryGetValue(s, out buff))
            {
                buff = new VBuffer();
                Buffers.Add(s, buff);
            }
            buff.mData.AddRange(datas);
            buff.mDimension = Mathf.Max(buff.mDimension, dimension);
        }
        public void AddTrangle(IEnumerable<int> collection)
        {
            Trangles.AddRange(collection);
        }
        public void Clear()
        {
            Trangles.Clear();
            Buffers.Clear();
        }
        public string GetInfo()
        {
            StringBuilder sb = new StringBuilder();
            sb.Append(Name+"\n");
            sb.Append("Trangle num:" + Trangles.Count / 3 + "\n");
            foreach (var p in Buffers)
            {
                var buff = p.Value;
                if (buff.mData.Count > 0)
                {
                    sb.Append(p.Key.ToString() + " num:" + buff.mData.Count + " dim:" + buff.mDimension + "\n");

                }
            }
            return sb.ToString();
        }

        public Mesh ToMesh(bool inverseX = false)
        {
            Mesh mesh = new Mesh();
            mesh.name = Name;
            foreach(var pair in Buffers)
            {
                ESemantic s = pair.Key;
                VBuffer buff = pair.Value;
                switch (s)
                {
                    case ESemantic.Position:
                        mesh.SetVertices(vector4to3(buff.mData,inverseX));
                        break;
                    case ESemantic.Normal:
                        mesh.SetNormals(vector4to3(buff.mData));
                        break;
                    case ESemantic.Color:
                        mesh.SetColors(vector4toColor(buff.mData));
                        break;
                    case ESemantic.Tangent:
                        mesh.SetTangents(buff.mData);
                        break;
                    case ESemantic.Coord0:
                    case ESemantic.Coord1:
                    case ESemantic.Coord2:
                    case ESemantic.Coord3:
                    case ESemantic.Coord4:
                        int c = (int)s - (int)ESemantic.Coord0;
                        switch(buff.mDimension)
                        {
                            case 2:
                                mesh.SetUVs(c, vector4to2(buff.mData));
                                break;
                            case 3:
                                mesh.SetUVs(c, vector4to3(buff.mData));
                                break;
                            case 4:
                                mesh.SetUVs(c, buff.mData);
                                break;
                            default:
                                Debug.LogWarning("buffer dimention warning:" + s + "-" + buff.mDimension);
                                break;
                        }

                        break;
                    default:
                        Debug.LogWarning("unsuport buffer:" + s);
                        break;

                }
            }

            int[] triangles = new int[Trangles.Count];
            for (int i = 0; i < Trangles.Count / 3; i++)
            {
                triangles[i * 3] = Trangles[i * 3];
                if (inverseX)
                {
                    triangles[i * 3 + 1] = Trangles[i * 3 + 2];
                    triangles[i * 3 + 2] = Trangles[i * 3 + 1];
                }
                else
                {
                    triangles[i * 3 + 1] = Trangles[i * 3 + 1];
                    triangles[i * 3 + 2] = Trangles[i * 3 + 2];
                }
            }
            mesh.SetTriangles(triangles, 0);
            return mesh;
        }

        private List<Vector2> vector4to2(List<Vector4> vs)
        {
            Vector2[] vec2s = new Vector2[vs.Count];
            for(int i = 0;i<vs.Count;i++)
            {
                vec2s[i].x = vs[i].x;
                vec2s[i].y = vs[i].y;
            }
            List<Vector2> list = new List<Vector2>(vec2s);
            return list;
        }

        private List<Vector3> vector4to3(List<Vector4> vs,bool inverseX = false)
        {
            Vector3[] vec3s = new Vector3[vs.Count];
            for (int i = 0; i < vs.Count; i++)
            {
                if(inverseX)
                    vec3s[i].x = -vs[i].x;
                else
                    vec3s[i].x = vs[i].x;

                vec3s[i].y = vs[i].y;
                vec3s[i].z = vs[i].z;
            }
            List<Vector3> list = new List<Vector3>(vec3s);
            return list;
        }
        private List<Color> vector4toColor(List<Vector4> vs)
        {
            Color[] cs = new Color[vs.Count];
            for (int i = 0; i < vs.Count; i++)
            {
                cs[i].r = vs[i].x;
                cs[i].g = vs[i].y;
                cs[i].b = vs[i].z;
                cs[i].a = vs[i].w;
            }
            List<Color> list = new List<Color>(cs);
            return list;
        }
    }
}