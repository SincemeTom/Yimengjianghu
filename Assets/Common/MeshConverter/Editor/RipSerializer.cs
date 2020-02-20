using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using System;
using System.Text;

namespace UnityEngine {
    
    public class RipAttributeElement {
        public string name;
        public uint bytesOffset;
        public uint dimension;

        //设置的语意
        public ESemantic sematic;
    }

    public class RipData {
        public string meshName;
        //顶点数据列表
        public float[] vertexData;
        //索引数据列表
        public uint[] indexData;
        //单个顶点数据大小
        public uint vertexBytesSize;
        //顶点数量
        public uint vertexCount;
        //索引数量
        public uint indexCount;
        //单个顶点属性种类
        public uint attributeCountPerVertex;
        //顶点属性
        public RipAttributeElement[] elements;
        //单个顶点元素数量
        public uint dimensionPerVertex;

        public string[] textureFiles;
        public string[] shaderFiles;

        public string GetInfo() {
            StringBuilder sb = new StringBuilder();
            sb.Append(meshName + "\n");
            sb.AppendFormat("Vertex Count:{0}\n",vertexCount);
            sb.AppendFormat("Tringle Count:{0}\n", indexCount / 3);
            sb.AppendFormat("Attribute Count:{0}\n", attributeCountPerVertex);
            sb.AppendFormat("Elements Count:{0}\n", dimensionPerVertex);
            sb.Append("\nTexture Files:\n\n");
            for(int i = 0; i < textureFiles.Length; ++i) {
                sb.Append(textureFiles[i] + "\n");
            }
            sb.Append("\nShader Files:\n");
            for (int i = 0; i < shaderFiles.Length; ++i) {
                sb.Append(shaderFiles[i] + "\n");
            }
            return sb.ToString();
        }
    }

    public class RipSerializer {
        private const uint RipFileVersion = 4;

        public RipData Load(string path) {
            BinaryReader reader = null;
            RipData ripData = null;
            try {
                if (string.IsNullOrEmpty(path))
                    return null;
                reader = new BinaryReader(File.Open(path, FileMode.Open));
            } catch (Exception e) {
                if (null != reader) reader.Close();
                Debug.LogError("打开文件失败：" + path + "\n" + e.Message);
                return null;
            }

            int id = path.LastIndexOf("/");
            string name = path.Substring(id + 1);

            reader.ReadUInt32(); //signature
            uint version = reader.ReadUInt32();
            if (version == RipFileVersion) {
                uint dwFacesCnt = reader.ReadUInt32();
                uint dwVertexesCnt = reader.ReadUInt32();
                uint vertexSize = reader.ReadUInt32();
                uint textureFilesCnt = reader.ReadUInt32();
                uint shaderFilesCnt = reader.ReadUInt32();
                uint vertexAttributesCnt = reader.ReadUInt32();
                List<uint> vertexAttribTypesArray = new List<uint>();
                List<string> textureFiles = new List<string>();
                List<string> shaderFiles = new List<string>();

                //attributes
                List<float> vertexArray = new List<float>();
                List<uint> faceArray = new List<uint>();
                List<RipAttributeElement> elements = new List<RipAttributeElement>();

                for (int i = 0; i < vertexAttributesCnt; ++i) {
                    RipAttributeElement elem = new RipAttributeElement();
                    string semantic = ReadStr(reader);
                    uint semanticIndex = reader.ReadUInt32();
                    uint offset = reader.ReadUInt32();
                    uint size = reader.ReadUInt32();
                    uint typeMapElements = reader.ReadUInt32();
                    for (int j = 0; j < typeMapElements; ++j) {
                        uint typeElement = reader.ReadUInt32();
                        vertexAttribTypesArray.Add(typeElement);
                    }

                    elem.name = semantic + semanticIndex;
                    elem.bytesOffset = offset;
                    elem.dimension = size / 4;
                    elem.sematic = ESemantic.UnKnown;
                    elements.Add(elem);
                }

                //read textures
                for (int i = 0; i < textureFilesCnt; ++i) {
                    textureFiles.Add(ReadStr(reader));
                }

                //read Shaders
                for (int i = 0; i < shaderFilesCnt; ++i) {
                    shaderFiles.Add(ReadStr(reader));
                }

                //read indices
                for (int i = 0; i < dwFacesCnt; ++i) {
                    faceArray.Add(reader.ReadUInt32());
                    faceArray.Add(reader.ReadUInt32());
                    faceArray.Add(reader.ReadUInt32());
                }

                //read vertexes
                for (int i = 0; i < dwVertexesCnt; ++i) {                 
                    for (int j = 0; j < vertexAttribTypesArray.Count; ++j) {
                        uint elementType = vertexAttribTypesArray[j];
                        float z = 0.0f;
                        if (elementType == 0) {  //float
                            z = reader.ReadSingle();
                        } else if (elementType == 1) { //uint
                            z = reader.ReadUInt32();
                        } else if (elementType == 2) { //int
                            z = reader.ReadInt32();
                        } else {
                            z = reader.ReadUInt32();
                        }
                        vertexArray.Add(Convert.ToSingle(z));
                    }
                }

                //构造rip文件
                ripData = new RipData();
                ripData.meshName = path.Substring(path.LastIndexOf("/") + 1);
                ripData.vertexData = vertexArray.ToArray();
                ripData.indexData = faceArray.ToArray();
                ripData.vertexBytesSize = vertexSize;
                ripData.vertexCount = dwVertexesCnt;
                ripData.indexCount = dwFacesCnt * 3;
                ripData.attributeCountPerVertex = vertexAttributesCnt;
                ripData.dimensionPerVertex =  Convert.ToUInt32(vertexAttribTypesArray.Count);
                ripData.elements = elements.ToArray();
                ripData.textureFiles = textureFiles.ToArray();
                ripData.shaderFiles = shaderFiles.ToArray();
            } else {
                Debug.LogError("Rip文件:" + name + "版本错误");          
            }
            return ripData;
        }

        private string ReadStr(BinaryReader br) {
            string result = "";
            while (true) {
                int str = br.ReadByte();
                if (str == 0) break;
                result += Convert.ToChar(str);
            }
            return result;
        }

    }

}
