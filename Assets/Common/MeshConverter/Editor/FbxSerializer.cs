using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEngine;

public class FbxSerializer : MonoBehaviour {


    public static void WriteMeshFBX(MeshData mesh, string path)
    {
        var timestamp = DateTime.Now;

        using (StreamWriter FBXwriter = new StreamWriter(path))
        {
            StringBuilder fbx = new StringBuilder();
            StringBuilder ob = new StringBuilder(); //Objects builder
            StringBuilder cb = new StringBuilder(); //Connections builder
            StringBuilder cb2 = new StringBuilder(); //and keep connections ordered
            cb.Append("\n}\n");//Objects end
            cb.Append("\nConnections:  {");

            //write connections here and Mesh objects separately without having to backtrack through their MEshFilter to het the GameObject ID
            //also note that MeshFilters are not unique, they cannot be used for instancing geometry
            cb2.AppendFormat("\n\n\t;Geometry::, Model::{0}", mesh.Name);
            cb2.AppendFormat("\n\tC: \"OO\",3{0},1{1}", 2, 1);

            #region write generic FBX data after everything was collected
            fbx.Append("; FBX 7.1.0 project file");
            fbx.Append("\nFBXHeaderExtension:  {\n\tFBXHeaderVersion: 1003\n\tFBXVersion: 7100\n\tCreationTimeStamp:  {\n\t\tVersion: 1000");
            fbx.Append("\n\t\tYear: " + timestamp.Year);
            fbx.Append("\n\t\tMonth: " + timestamp.Month);
            fbx.Append("\n\t\tDay: " + timestamp.Day);
            fbx.Append("\n\t\tHour: " + timestamp.Hour);
            fbx.Append("\n\t\tMinute: " + timestamp.Minute);
            fbx.Append("\n\t\tSecond: " + timestamp.Second);
            fbx.Append("\n\t\tMillisecond: " + timestamp.Millisecond);
            fbx.Append("\n\t}\n\tCreator: \"Unity Studio by Chipicao\"\n}\n");

            fbx.Append("\nGlobalSettings:  {");
            fbx.Append("\n\tVersion: 1000");
            fbx.Append("\n\tProperties70:  {");
            fbx.Append("\n\t\tP: \"UpAxis\", \"int\", \"Integer\", \"\",1");
            fbx.Append("\n\t\tP: \"UpAxisSign\", \"int\", \"Integer\", \"\",1");
            fbx.Append("\n\t\tP: \"FrontAxis\", \"int\", \"Integer\", \"\",2");
            fbx.Append("\n\t\tP: \"FrontAxisSign\", \"int\", \"Integer\", \"\",1");
            fbx.Append("\n\t\tP: \"CoordAxis\", \"int\", \"Integer\", \"\",0");
            fbx.Append("\n\t\tP: \"CoordAxisSign\", \"int\", \"Integer\", \"\",1");
            fbx.Append("\n\t\tP: \"OriginalUpAxis\", \"int\", \"Integer\", \"\",1");
            fbx.Append("\n\t\tP: \"OriginalUpAxisSign\", \"int\", \"Integer\", \"\",1");
            fbx.AppendFormat("\n\t\tP: \"UnitScaleFactor\", \"double\", \"Number\", \"\",{0}", 1);
            fbx.Append("\n\t\tP: \"OriginalUnitScaleFactor\", \"double\", \"Number\", \"\",1.0");
            //fbx.Append("\n\t\tP: \"AmbientColor\", \"ColorRGB\", \"Color\", \"\",0,0,0");
            //fbx.Append("\n\t\tP: \"DefaultCamera\", \"KString\", \"\", \"\", \"Producer Perspective\"");
            //fbx.Append("\n\t\tP: \"TimeMode\", \"enum\", \"\", \"\",6");
            //fbx.Append("\n\t\tP: \"TimeProtocol\", \"enum\", \"\", \"\",2");
            //fbx.Append("\n\t\tP: \"SnapOnFrameMode\", \"enum\", \"\", \"\",0");
            //fbx.Append("\n\t\tP: \"TimeSpanStart\", \"KTime\", \"Time\", \"\",0");
            //fbx.Append("\n\t\tP: \"TimeSpanStop\", \"KTime\", \"Time\", \"\",153953860000");
            //fbx.Append("\n\t\tP: \"CustomFrameRate\", \"double\", \"Number\", \"\",-1");
            //fbx.Append("\n\t\tP: \"TimeMarker\", \"Compound\", \"\", \"\"");
            //fbx.Append("\n\t\tP: \"CurrentTimeMarker\", \"int\", \"Integer\", \"\",-1");
            fbx.Append("\n\t}\n}\n");

            fbx.Append("\nDocuments:  {");
            fbx.Append("\n\tCount: 1");
            fbx.Append("\n\tDocument: 1234567890, \"\", \"Scene\" {");
            fbx.Append("\n\t\tProperties70:  {");
            fbx.Append("\n\t\t\tP: \"SourceObject\", \"object\", \"\", \"\"");
            fbx.Append("\n\t\t\tP: \"ActiveAnimStackName\", \"KString\", \"\", \"\", \"\"");
            fbx.Append("\n\t\t}");
            fbx.Append("\n\t\tRootNode: 0");
            fbx.Append("\n\t}\n}\n");
            fbx.Append("\nReferences:  {\n}\n");

            fbx.Append("\nDefinitions:  {");
            fbx.Append("\n\tVersion: 100");
            fbx.AppendFormat("\n\tCount: {0}", 2);

            fbx.Append("\n\tObjectType: \"GlobalSettings\" {");
            fbx.Append("\n\t\tCount: 1");
            fbx.Append("\n\t}");

            fbx.Append("\n\tObjectType: \"Model\" {");
            fbx.AppendFormat("\n\t\tCount: {0}", 1);
            fbx.Append("\n\t}");

            fbx.Append("\n\tObjectType: \"NodeAttribute\" {");
            fbx.AppendFormat("\n\t\tCount: {0}", 0);
            fbx.Append("\n\t\tPropertyTemplate: \"FbxNull\" {");
            fbx.Append("\n\t\t\tProperties70:  {");
            fbx.Append("\n\t\t\t\tP: \"Color\", \"ColorRGB\", \"Color\", \"\",0.8,0.8,0.8");
            fbx.Append("\n\t\t\t\tP: \"Size\", \"double\", \"Number\", \"\",100");
            fbx.Append("\n\t\t\t\tP: \"Look\", \"enum\", \"\", \"\",1");
            fbx.Append("\n\t\t\t}\n\t\t}\n\t}");

            fbx.Append("\n\tObjectType: \"Geometry\" {");
            fbx.AppendFormat("\n\t\tCount: {0}", 1);
            fbx.Append("\n\t}");

            fbx.Append("\n\tObjectType: \"Material\" {");
            fbx.AppendFormat("\n\t\tCount: {0}", 0);
            fbx.Append("\n\t}");

            fbx.Append("\n\tObjectType: \"Texture\" {");
            fbx.AppendFormat("\n\t\tCount: {0}", 0);
            fbx.Append("\n\t}");

            fbx.Append("\n\tObjectType: \"Video\" {");
            fbx.AppendFormat("\n\t\tCount: {0}", 0);
            fbx.Append("\n\t}");


            fbx.Append("\n}\n");
            fbx.Append("\nObjects:  {");

            FBXwriter.Write(fbx);
            #endregion

            #region write Model nodes and connections
            ob.AppendFormat("\n\tModel: 1{0}, \"Model::{1}\", \"Mesh\" {{", 1, mesh.Name);

            ob.Append("\n\t\tVersion: 232");
            ob.Append("\n\t\tProperties70:  {");
            ob.Append("\n\t\t\tP: \"InheritType\", \"enum\", \"\", \"\",1");
            ob.Append("\n\t\t\tP: \"ScalingMax\", \"Vector3D\", \"Vector\", \"\",0,0,0");
            ob.Append("\n\t\t\tP: \"DefaultAttributeIndex\", \"int\", \"Integer\", \"\",0");

            //mb.Append("\n\t\t\tP: \"UDP3DSMAX\", \"KString\", \"\", \"U\", \"MapChannel:1 = UVChannel_1&cr;&lf;MapChannel:2 = UVChannel_2&cr;&lf;\"");
            //mb.Append("\n\t\t\tP: \"MaxHandle\", \"int\", \"Integer\", \"UH\",24");
            ob.Append("\n\t\t}");
            ob.Append("\n\t\tShading: T");
            ob.Append("\n\t\tCulling: \"CullingOff\"\n\t}");

            cb.AppendFormat("\n\n\t;Model::{0}, Model::RootNode", mesh.Name);
            cb.AppendFormat("\n\tC: \"OO\",1{0},0", 1);
            #endregion

            MeshFBX(mesh, "2", ob);

            //write data 8MB at a time
            if (ob.Length > (8 * 0x100000))
            { FBXwriter.Write(ob); }


            cb.Append(cb2);

            FBXwriter.Write(ob);

            cb.Append("\n}");//Connections end
            FBXwriter.Write(cb);

        }
    }

    private static void MeshFBX(MeshData m_Mesh, string MeshID, StringBuilder ob)
    {
        int vertexNum = m_Mesh.GetVertexCount();
        if (vertexNum > 0)//general failsafe
        {
            //StatusStripUpdate("Writing Geometry: " + m_Mesh.m_Name);

            ob.AppendFormat("\n\tGeometry: 3{0}, \"Geometry::\", \"Mesh\" {{", MeshID);
            ob.Append("\n\t\tProperties70:  {");
            var randomColor = RandomColorGenerator(m_Mesh.Name);
            ob.AppendFormat("\n\t\t\tP: \"Color\", \"ColorRGB\", \"Color\", \"\",{0},{1},{2}", ((float)randomColor[0] / 255), ((float)randomColor[1] / 255), ((float)randomColor[2] / 255));
            ob.Append("\n\t\t}");

            #region Vertices
            MeshData.VBuffer buff = m_Mesh.Buffers[ESemantic.Position];
            ob.AppendFormat("\n\t\tVertices: *{0} {{\n\t\t\ta: ", vertexNum * 3);
            
            int lineSplit = ob.Length;
            for (int v = 0; v < vertexNum; v++)
            {
                ob.AppendFormat("{0},{1},{2},", buff.mData[v].x, buff.mData[v].y, buff.mData[v].z);

                if (ob.Length - lineSplit > 2000)
                {
                    ob.Append("\n");
                    lineSplit = ob.Length;
                }
            }
            ob.Length--;//remove last comma
            ob.Append("\n\t\t}");
            #endregion
            #region Indices
            int indexNum = m_Mesh.GetIndexCount();
            //in order to test topology for triangles/quads we need to store submeshes and write each one as geometry, then link to Mesh Node
            ob.AppendFormat("\n\t\tPolygonVertexIndex: *{0} {{\n\t\t\ta: ", indexNum);

            lineSplit = ob.Length;
            for (int f = 0; f < indexNum / 3; f++)
            {
                ob.AppendFormat("{0},{1},{2},", m_Mesh.Trangles[f * 3], m_Mesh.Trangles[f * 3 + 1], (-m_Mesh.Trangles[f * 3 + 2] - 1));

                if (ob.Length - lineSplit > 2000)
                {
                    ob.Append("\n");
                    lineSplit = ob.Length;
                }
            }
            ob.Length--;//remove last comma

            ob.Append("\n\t\t}");
            ob.Append("\n\t\tGeometryVersion: 124");
            #endregion

            #region Normals
            
            if (m_Mesh.Buffers.TryGetValue(ESemantic.Normal,out buff))
            {
                ob.Append("\n\t\tLayerElementNormal: 0 {");
                ob.Append("\n\t\t\tVersion: 101");
                ob.Append("\n\t\t\tName: \"\"");
                ob.Append("\n\t\t\tMappingInformationType: \"ByVertice\"");
                ob.Append("\n\t\t\tReferenceInformationType: \"Direct\"");
                ob.AppendFormat("\n\t\t\tNormals: *{0} {{\n\t\t\ta: ", (vertexNum * 3));

                lineSplit = ob.Length;
                for (int v = 0; v < vertexNum; v++)
                {
                    ob.AppendFormat("{0},{1},{2},", buff.mData[v].x, buff.mData[v].y, buff.mData[v].z);

                    if (ob.Length - lineSplit > 2000)
                    {
                        ob.Append("\n");
                        lineSplit = ob.Length;
                    }
                }
                ob.Length--;//remove last comma
                ob.Append("\n\t\t\t}\n\t\t}");
            }
            #endregion


            #region Binormals
            if (m_Mesh.Buffers.TryGetValue(ESemantic.BNormal, out buff))
            {
                ob.Append("\n\t\tLayerElementBinormal: 0 {");
                ob.Append("\n\t\t\tVersion: 101");
                ob.Append("\n\t\t\tName: \"\"");
                ob.Append("\n\t\t\tMappingInformationType: \"ByVertice\"");
                ob.Append("\n\t\t\tReferenceInformationType: \"Direct\"");
                ob.AppendFormat("\n\t\t\tBinormals: *{0} {{\n\t\t\ta: ", (vertexNum * 3));

                lineSplit = ob.Length;
                for (int v = 0; v < vertexNum; v++)
                {
                    if (buff.mDimension == 3)
                        ob.AppendFormat("{0},{1},{2},", buff.mData[v].x, buff.mData[v].y, buff.mData[v].z);
                    else
                        ob.AppendFormat("{0},{1},{2},", buff.mData[v].x * buff.mData[v].w, buff.mData[v].y * buff.mData[v].w, buff.mData[v].z * buff.mData[v].w);

                    if (ob.Length - lineSplit > 2000)
                    {
                        ob.Append("\n");
                        lineSplit = ob.Length;
                    }
                }
                ob.Length--;//remove last comma
                ob.Append("\n\t\t\t}\n\t\t}");
            }
            #endregion

            #region Tangents
            if (m_Mesh.Buffers.TryGetValue(ESemantic.Tangent, out buff))
            {
                ob.Append("\n\t\tLayerElementTangent: 0 {");
                ob.Append("\n\t\t\tVersion: 101");
                ob.Append("\n\t\t\tName: \"\"");
                ob.Append("\n\t\t\tMappingInformationType: \"ByVertice\"");
                ob.Append("\n\t\t\tReferenceInformationType: \"Direct\"");
                ob.AppendFormat("\n\t\t\tTangents: *{0} {{\n\t\t\ta: ", (vertexNum * 3));

                lineSplit = ob.Length;
                for (int v = 0; v < vertexNum; v++)
                {
                    if (buff.mDimension == 3)
                        ob.AppendFormat("{0},{1},{2},", buff.mData[v].x, buff.mData[v].y, buff.mData[v].z);
                    else
                        ob.AppendFormat("{0},{1},{2},", buff.mData[v].x * buff.mData[v].w, buff.mData[v].y * buff.mData[v].w, buff.mData[v].z * buff.mData[v].w);

                    if (ob.Length - lineSplit > 2000)
                    {
                        ob.Append("\n");
                        lineSplit = ob.Length;
                    }
                }
                ob.Length--;//remove last comma
                ob.Append("\n\t\t\t}\n\t\t}");
            }
            #endregion

            #region Colors
            if (m_Mesh.Buffers.TryGetValue(ESemantic.Color, out buff))
            {
                ob.Append("\n\t\tLayerElementColor: 0 {");
                ob.Append("\n\t\t\tVersion: 101");
                ob.Append("\n\t\t\tName: \"\"");
                //ob.Append("\n\t\t\tMappingInformationType: \"ByVertice\"");
                //ob.Append("\n\t\t\tReferenceInformationType: \"Direct\"");
                ob.Append("\n\t\t\tMappingInformationType: \"ByPolygonVertex\"");
                ob.Append("\n\t\t\tReferenceInformationType: \"IndexToDirect\"");
                ob.AppendFormat("\n\t\t\tColors: *{0} {{\n\t\t\ta: ", vertexNum * 4);
                //ob.Append(string.Join(",", m_Mesh.m_Colors));

                lineSplit = ob.Length;
                if (buff.mDimension == 3)
                {
                    for (int i = 0; i < vertexNum; i++)
                    {
                        ob.AppendFormat("{0},{1},{2},{3},", buff.mData[i].x, buff.mData[i].y, buff.mData[i].z, 1.0f);
                        if (ob.Length - lineSplit > 2000)
                        {
                            ob.Append("\n");
                            lineSplit = ob.Length;
                        }
                    }
                }
                else
                {
                    for (int i = 0; i < vertexNum; i++)
                    {
                        ob.AppendFormat("{0},{1},{2},{3},", buff.mData[i].x, buff.mData[i].y, buff.mData[i].z, buff.mData[i].w);
                        if (ob.Length - lineSplit > 2000)
                        {
                            ob.Append("\n");
                            lineSplit = ob.Length;
                        }
                    }
                }
                ob.Length--;//remove last comma

                ob.Append("\n\t\t\t}");
                ob.AppendFormat("\n\t\t\tColorIndex: *{0} {{\n\t\t\ta: ", indexNum);

                lineSplit = ob.Length;
                for (int f = 0; f < indexNum / 3; f++)
                {
                    ob.AppendFormat("{0},{1},{2},", m_Mesh.Trangles[f * 3], m_Mesh.Trangles[f * 3 + 1], (m_Mesh.Trangles[f * 3 + 2]));

                    if (ob.Length - lineSplit > 2000)
                    {
                        ob.Append("\n");
                        lineSplit = ob.Length;
                    }
                }
                ob.Length--;//remove last comma

                ob.Append("\n\t\t\t}\n\t\t}");
            }
            #endregion

            #region UV1
            //does FBX support UVW coordinates?
            if (m_Mesh.Buffers.TryGetValue(ESemantic.Coord0, out buff))
            {
                ob.Append("\n\t\tLayerElementUV: 0 {");
                ob.Append("\n\t\t\tVersion: 101");
                ob.Append("\n\t\t\tName: \"UVChannel_1\"");
                ob.Append("\n\t\t\tMappingInformationType: \"ByVertice\"");
                ob.Append("\n\t\t\tReferenceInformationType: \"Direct\"");
                ob.AppendFormat("\n\t\t\tUV: *{0} {{\n\t\t\ta: ", vertexNum * buff.mDimension);

                lineSplit = ob.Length;
                for (int v = 0; v < vertexNum; v++)
                {
                    for(int j = 0;j<buff.mDimension;j++)
                    {
                        ob.AppendFormat("{0},", buff.mData[v][j]);
                    }

                    if (ob.Length - lineSplit > 2000)
                    {
                        ob.Append("\n");
                        lineSplit = ob.Length;
                    }
                }
                ob.Length--;//remove last comma
                ob.Append("\n\t\t\t}\n\t\t}");
            }
            #endregion
            #region UV2
            if (m_Mesh.Buffers.TryGetValue(ESemantic.Coord1, out buff))
            {
                ob.Append("\n\t\tLayerElementUV: 1 {");
                ob.Append("\n\t\t\tVersion: 101");
                ob.Append("\n\t\t\tName: \"UVChannel_2\"");
                ob.Append("\n\t\t\tMappingInformationType: \"ByVertice\"");
                ob.Append("\n\t\t\tReferenceInformationType: \"Direct\"");
                ob.AppendFormat("\n\t\t\tUV: *{0} {{\n\t\t\ta: ", vertexNum * buff.mDimension);

                lineSplit = ob.Length;
                for (int v = 0; v < vertexNum; v++)
                {
                    for (int j = 0; j < buff.mDimension; j++)
                    {
                        ob.AppendFormat("{0},", buff.mData[v][j]);
                    }

                    if (ob.Length - lineSplit > 2000)
                    {
                        ob.Append("\n");
                        lineSplit = ob.Length;
                    }
                }
                ob.Length--;//remove last comma
                ob.Append("\n\t\t\t}\n\t\t}");
            }
            #endregion
            #region UV3
            if (m_Mesh.Buffers.TryGetValue(ESemantic.Coord2, out buff))
            {
                ob.Append("\n\t\tLayerElementUV: 2 {");
                ob.Append("\n\t\t\tVersion: 101");
                ob.Append("\n\t\t\tName: \"UVChannel_3\"");
                ob.Append("\n\t\t\tMappingInformationType: \"ByVertice\"");
                ob.Append("\n\t\t\tReferenceInformationType: \"Direct\"");
                ob.AppendFormat("\n\t\t\tUV: *{0} {{\n\t\t\ta: ", vertexNum * buff.mDimension);

                lineSplit = ob.Length;
                for (int v = 0; v < vertexNum; v++)
                {
                    for (int j = 0; j < buff.mDimension; j++)
                    {
                        ob.AppendFormat("{0},", buff.mData[v][j]);
                    }

                    if (ob.Length - lineSplit > 2000)
                    {
                        ob.Append("\n");
                        lineSplit = ob.Length;
                    }
                }
                ob.Length--;//remove last comma
                ob.Append("\n\t\t\t}\n\t\t}");
            }
            #endregion
            #region UV4
            if (m_Mesh.Buffers.TryGetValue(ESemantic.Coord3, out buff))
            {
                ob.Append("\n\t\tLayerElementUV: 3 {");
                ob.Append("\n\t\t\tVersion: 101");
                ob.Append("\n\t\t\tName: \"UVChannel_4\"");
                ob.Append("\n\t\t\tMappingInformationType: \"ByVertice\"");
                ob.Append("\n\t\t\tReferenceInformationType: \"Direct\"");
                ob.AppendFormat("\n\t\t\tUV: *{0} {{\n\t\t\ta: ", vertexNum * buff.mDimension);

                lineSplit = ob.Length;
                for (int v = 0; v < vertexNum; v++)
                {
                    for (int j = 0; j < buff.mDimension; j++)
                    {
                        ob.AppendFormat("{0},", buff.mData[v][j]);
                    }

                    if (ob.Length - lineSplit > 2000)
                    {
                        ob.Append("\n");
                        lineSplit = ob.Length;
                    }
                }
                ob.Length--;//remove last comma
                ob.Append("\n\t\t\t}\n\t\t}");
            }
            #endregion

            #region Material
            ob.Append("\n\t\tLayerElementMaterial: 0 {");
            ob.Append("\n\t\t\tVersion: 101");
            ob.Append("\n\t\t\tName: \"\"");
            ob.Append("\n\t\t\tMappingInformationType: \"");
            //if (m_Mesh.m_SubMeshes.Count == 1)
            { ob.Append("AllSame\""); }
            //else { ob.Append("ByPolygon\""); }
            ob.Append("\n\t\t\tReferenceInformationType: \"IndexToDirect\"");
            ob.AppendFormat("\n\t\t\tMaterials: *{0} {{", 0);
            ob.Append("\n\t\t\t\t");
            //if (m_Mesh.m_SubMeshes.Count == 1)
            { ob.Append("0"); }
            //else
            //{
            //    lineSplit = ob.Length;
            //    for (int i = 0; i < m_Mesh.m_materialIDs.Count; i++)
            //    {
            //        ob.AppendFormat("{0},", m_Mesh.m_materialIDs[i]);

            //        if (ob.Length - lineSplit > 2000)
            //        {
            //            ob.Append("\n");
            //            lineSplit = ob.Length;
            //        }
            //    }
            //    ob.Length--;//remove last comma
            //}
            ob.Append("\n\t\t\t}\n\t\t}");
            #endregion

            #region Layers
            ob.Append("\n\t\tLayer: 0 {");
            ob.Append("\n\t\t\tVersion: 100");
            if (m_Mesh.Buffers.ContainsKey(ESemantic.Normal))
            {
                ob.Append("\n\t\t\tLayerElement:  {");
                ob.Append("\n\t\t\t\tType: \"LayerElementNormal\"");
                ob.Append("\n\t\t\t\tTypedIndex: 0");
                ob.Append("\n\t\t\t}");
            }
            if (m_Mesh.Buffers.ContainsKey(ESemantic.BNormal))
            {
                ob.Append("\n\t\t\tLayerElement:  {");
                ob.Append("\n\t\t\t\tType: \"LayerElementBinormal\"");
                ob.Append("\n\t\t\t\tTypedIndex: 0");
                ob.Append("\n\t\t\t}");
            }
            if (m_Mesh.Buffers.ContainsKey(ESemantic.Tangent))
            {
                ob.Append("\n\t\t\tLayerElement:  {");
                ob.Append("\n\t\t\t\tType: \"LayerElementTangent\"");
                ob.Append("\n\t\t\t\tTypedIndex: 0");
                ob.Append("\n\t\t\t}");
            }
            ob.Append("\n\t\t\tLayerElement:  {");
            ob.Append("\n\t\t\t\tType: \"LayerElementMaterial\"");
            ob.Append("\n\t\t\t\tTypedIndex: 0");
            ob.Append("\n\t\t\t}");
            //
            /*ob.Append("\n\t\t\tLayerElement:  {");
            ob.Append("\n\t\t\t\tType: \"LayerElementTexture\"");
            ob.Append("\n\t\t\t\tTypedIndex: 0");
            ob.Append("\n\t\t\t}");
            ob.Append("\n\t\t\tLayerElement:  {");
            ob.Append("\n\t\t\t\tType: \"LayerElementBumpTextures\"");
            ob.Append("\n\t\t\t\tTypedIndex: 0");
            ob.Append("\n\t\t\t}");*/
            if (m_Mesh.Buffers.ContainsKey(ESemantic.Color))
            {
                ob.Append("\n\t\t\tLayerElement:  {");
                ob.Append("\n\t\t\t\tType: \"LayerElementColor\"");
                ob.Append("\n\t\t\t\tTypedIndex: 0");
                ob.Append("\n\t\t\t}");
            }
            if (m_Mesh.Buffers.ContainsKey(ESemantic.Coord0))
            {
                ob.Append("\n\t\t\tLayerElement:  {");
                ob.Append("\n\t\t\t\tType: \"LayerElementUV\"");
                ob.Append("\n\t\t\t\tTypedIndex: 0");
                ob.Append("\n\t\t\t}");
            }
            ob.Append("\n\t\t}"); //Layer 0 end

            if (m_Mesh.Buffers.ContainsKey(ESemantic.Coord1))
            {
                ob.Append("\n\t\tLayer: 1 {");
                ob.Append("\n\t\t\tVersion: 100");
                ob.Append("\n\t\t\tLayerElement:  {");
                ob.Append("\n\t\t\t\tType: \"LayerElementUV\"");
                ob.Append("\n\t\t\t\tTypedIndex: 1");
                ob.Append("\n\t\t\t}");
                ob.Append("\n\t\t}"); //Layer 1 end
            }

            if (m_Mesh.Buffers.ContainsKey(ESemantic.Coord2))
            {
                ob.Append("\n\t\tLayer: 2 {");
                ob.Append("\n\t\t\tVersion: 100");
                ob.Append("\n\t\t\tLayerElement:  {");
                ob.Append("\n\t\t\t\tType: \"LayerElementUV\"");
                ob.Append("\n\t\t\t\tTypedIndex: 2");
                ob.Append("\n\t\t\t}");
                ob.Append("\n\t\t}"); //Layer 2 end
            }

            if (m_Mesh.Buffers.ContainsKey(ESemantic.Coord3))
            {
                ob.Append("\n\t\tLayer: 3 {");
                ob.Append("\n\t\t\tVersion: 100");
                ob.Append("\n\t\t\tLayerElement:  {");
                ob.Append("\n\t\t\t\tType: \"LayerElementUV\"");
                ob.Append("\n\t\t\t\tTypedIndex: 3");
                ob.Append("\n\t\t\t}");
                ob.Append("\n\t\t}"); //Layer 3 end
            }
            #endregion

            ob.Append("\n\t}"); //Geometry end
        }
    }

    private static byte[] RandomColorGenerator(string name)
    {
        int nameHash = name.GetHashCode();
        System.Random r = new System.Random(nameHash);
        //Random r = new Random(DateTime.Now.Millisecond);

        byte red = (byte)r.Next(0, 255);
        byte green = (byte)r.Next(0, 255);
        byte blue = (byte)r.Next(0, 255);

        return new byte[3] { red, green, blue };
    }

}
