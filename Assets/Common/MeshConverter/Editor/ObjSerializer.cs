using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using System;

namespace UnityEngine
{
    public class ObjSerializer
    {
        private MeshData mMesh;

        public MeshData Load(string path)
        {

            StreamReader reader = null;
            try
            {
                if (string.IsNullOrEmpty(path))
                    return null;
                reader = File.OpenText(path);
            }
            catch (Exception e)
            {
                reader.Close();
                Debug.LogError("打开文件失败：" + path + "\n" + e.Message);
                return null;
            }
            int id = path.LastIndexOf("/");
            string name = path.Substring(id+1);
            mMesh = new MeshData(name);

            string line = reader.ReadLine();
            char[] splits = { ' ', '\t' };
            while (line != null)
            {
                string[] elements = line.Split(splits);

                if (elements.Length > 1)
                {
                    switch (elements[0])
                    {
                        case "v":
                            AddData(ESemantic.Position, elements);
                            break;
                        case "vt":
                            AddData(ESemantic.Coord0, elements);
                            break;
                        case "vn":
                            AddData(ESemantic.Normal, elements);
                            break;
                        case "f":
                            AddTrangle(elements);
                            break;
                        default:
                            break;
                    }
                }

                line = reader.ReadLine();
            }
            reader.Close();
            return mMesh;
        }

        private void AddData(ESemantic s, string[] elements)
        {
            Vector4 v = new Vector4();
            for (int i = 1; i < elements.Length; i++)
            {
                if (i > 4)
                    break;
                v[i - 1] = float.Parse(elements[i]);

            }
            mMesh.AddData(s, v, elements.Length - 1);
        }

        private void AddTrangle(string[] elements)
        {
            if (elements.Length != 4)
            {
                Debug.LogWarning("三角形解析错误！" + elements.ToString());
                return;
            }
            int[] f = new int[3];
            for (int i = 1; i < 4; i++)
            {
                string ele = elements[i];
                int index = ele.IndexOf('/');
                if (index > 0)
                {
                    ele = ele.Substring(0, index);
                    //Debug.LogWarning("三角形解析错误！" + elements.ToString());
                    //return;
                }
                f[i - 1] = int.Parse(ele) - 1;
            }
            mMesh.AddTrangle(f);
        }
    }

}
