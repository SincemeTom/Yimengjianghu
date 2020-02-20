using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace UnityEngine
{
    [Serializable]
    public class ConvertStrategy : ISerializationCallbackReceiver
    {
        [System.Serializable]
        public enum ESlot
        {
            None = 0,
            SlotA = 1,
            SlotB = 2,
            SlotC = 3,
            SlotD = 4
        }
        [System.Serializable]
        public enum EPass
        {
            X = 0,
            Y = 1,
            Z = 2,
            W = 3
        }

        [System.Serializable]
        public class PassDataInfo
        {
            public ESlot Slot;
            public ESemantic Semantic;
            public EPass Pass;
            public PassDataInfo()
            {
                Slot = ESlot.None;
                Semantic = ESemantic.UnKnown;
                Pass = EPass.W;
            }
            public PassDataInfo(ESlot slot, ESemantic s, EPass pass)
            {
                Slot = slot;
                Semantic = s;
                Pass = pass;
            }
            public bool IsValid()
            {
                return (Slot != ConvertStrategy.ESlot.None && Semantic != ESemantic.UnKnown);
            }
        }

        [System.Serializable]
        public class BufferDataInfo
        {
            //public ESemantic Semantic;
            public PassDataInfo X;
            public PassDataInfo Y;
            public PassDataInfo Z;
            public PassDataInfo W;
            public BufferDataInfo(ESemantic s)
            {
                X = new PassDataInfo(ESlot.None, s, EPass.X);
                Y = new PassDataInfo(ESlot.None, s, EPass.Y);
                Z = new PassDataInfo(ESlot.None, s, EPass.Z);
                W = new PassDataInfo(ESlot.None, s, EPass.W);
            }

            public PassDataInfo this[int index]
            {
                get
                {
                    switch (index)
                    {
                        case 0:
                            return X;
                        case 1:
                            return Y;
                        case 2:
                            return Z;
                        case 3:
                            return W;
                        default:
                            return null;
                    }
                }
                set
                {
                    switch(index)
                    {
                        case 0:
                            X = value;
                            break;
                        case 1:
                            Y = value;
                            break;
                        case 2:
                            Z = value;
                            break;
                        case 3:
                            W = value;
                            break;
                        default:
                            break;
                    }
                }
            }
        }

        public MeshData SlotA;
        public MeshData SlotB;
        public MeshData SlotC;
        public MeshData SlotD;

        public string PostConvert = "";
        [SerializeField]
        SerializationMap1 mSerBufferInfos = new SerializationMap1(null);

        public Dictionary<ESemantic, BufferDataInfo> BufferInfos = new Dictionary<ESemantic, BufferDataInfo>();
        public MeshData this[int index]
        {
            get
            {
                switch (index)
                {
                    case 0:
                        return SlotA;
                    case 1:
                        return SlotB;
                    case 2:
                        return SlotC;
                    case 3:
                        return SlotD;
                    default:
                        return null;
                }
            }
            set
            {
                switch (index)
                {
                    case 0:
                        SlotA = value;
                        break;
                    case 1:
                        SlotB = value;
                        break;
                    case 2:
                        SlotC = value;
                        break;
                    case 3:
                        SlotD = value;
                        break;
                    default:
                        break;
                }
            }
        }

        public MeshData Convert(string newMeshName)
        {
            int id = CheckValid();
            if(id != 0)
            {
                Debug.LogError("转换失败："+ GetValidInfo(id));
                return null;
            }
            
            MeshData newMesh = new MeshData(newMeshName);
            MeshData slotmesh = SlotA == null ? SlotB : SlotA;
            if (slotmesh == null)
            {
                slotmesh = SlotC;
                if (slotmesh == null)
                {
                    slotmesh = SlotD;
                }
            }
            if (slotmesh == null)
                return null;
            int vertexNum = slotmesh.GetVertexCount();
            foreach (var pair in BufferInfos)
            {
                BufferDataInfo buff = pair.Value;
                ESemantic s = pair.Key;

                Vector4[] data = new Vector4[vertexNum];
                int dim = 0;
                for (int i = 0; i < 4; i++)
                {
                    var pass = buff[i];
                    if (pass.Slot == ESlot.None || pass.Semantic == ESemantic.UnKnown)
                    {
                        break;
                    }
                    var slot = this[(int)pass.Slot - 1];
                    for(int j = 0;j<vertexNum;j++)
                    {
                        data[j][i] = (slot.Buffers[pass.Semantic].mData[j])[(int)pass.Pass];
                    }
                    dim = i + 1;
                }
                if(dim > 0)
                {
                    newMesh.AddDataRange(s, data, dim);
                }
            }
            newMesh.AddTrangle(slotmesh.Trangles.ToArray());

            return newMesh;
        }
        public int CheckValid()
        {
            bool useSlotA = false;
            bool useSlotB = false;
            bool useSlotC = false;
            bool useSlotD = false;
            //find slots that are used
            foreach(var pair in BufferInfos)
            {
                var buff = pair.Value;
                for(int i = 0;i<4;i++)
                {
                    var slot = buff[i].Slot;
                    switch(slot)
                    {
                        case ESlot.SlotA:
                            useSlotA = true;
                            break;
                        case ESlot.SlotB:
                            useSlotB = true;
                            break;
                        case ESlot.SlotC:
                            useSlotC = true;
                            break;
                        case ESlot.SlotD:
                            useSlotD = true;
                            break;
                    }
                }
            }

            //Check if slots are available
            List<MeshData> list = new List<MeshData>();
            if (useSlotA)
            {
                if (SlotA == null || !SlotA.IsValid())
                    return 1;
                else
                {
                    if (!list.Contains(SlotA))
                        list.Add(SlotA);
                }
            }
            if (useSlotB)
            {
                if (SlotB == null || !SlotB.IsValid())
                    return 2;
                else
                {
                    if (!list.Contains(SlotB))
                        list.Add(SlotB);
                }
            }
            if (useSlotC)
            {
                if (SlotC == null || !SlotC.IsValid())
                    return 3;
                else
                {
                    if (!list.Contains(SlotC))
                        list.Add(SlotC);
                }
            }
            if (useSlotD)
            {
                if (SlotD == null || !SlotD.IsValid())
                    return 4;
                else
                {
                    if (!list.Contains(SlotD))
                        list.Add(SlotD);
                }
            }

            //check if slots could be conbined
            for(int i = 1;i<list.Count;i++)
            {
                bool b = CheckCombineAvailable(list[0], list[i]);
                if (!b)
                    return 5;
            }

            foreach (var pair in BufferInfos)
            {
                var buff = pair.Value;
                for (int i = 0; i < 4; i++)
                {
                    var pass = buff[i];
                    if(!CheckPassAvailable(pass))
                    {
                        int id = 1000 + (int)pair.Key * 10 + i;
                        return id;
                    }
                }
            }
            return 0;
        }

        private bool CheckCombineAvailable(MeshData a,MeshData b)
        {
            if(a.GetVertexCount() !=b.GetVertexCount() || a.GetIndexCount()!=b.GetIndexCount())
                return false;
         
            return true;
        }

        private bool CheckPassAvailable(PassDataInfo pass)
        {
            if (pass.Slot == ESlot.None || pass.Semantic == ESemantic.UnKnown)
                return true;
            var slot = this[(int)pass.Slot - 1];
            if (slot == null)
                return false;
            var s = pass.Semantic;
            MeshData.VBuffer buff;
            if(slot.Buffers.TryGetValue(s,out buff))
            {
                if (buff.mDimension > (int)pass.Pass)
                    return true;
            }

            return false;
        }
        public string GetValidInfo(int i)
        {
            switch (i)
            {
                case 0:
                    return "OK";
                case 1:
                    return "SlotA is not valid";
                case 2:
                    return "SlotB is not valid";
                case 3:
                    return "SlotC is not valid";
                case 4:
                    return "SlotD is not valid";
                case 5:
                    return "Vertex numbers or Index numbers are not match";
            }
            if (i > 1000)
            {
                i = i % 1000;
                int semantic = i / 10;
                int pass = i - semantic * 10;
                return "Invalid pass info:" + (ESemantic)semantic+"."+((EPass)pass);
            }
            return "unknown";
        }


        public void OnAfterDeserialize()
        {
            BufferInfos = mSerBufferInfos.ToDictionary();
        }

        public void OnBeforeSerialize()
        {
            mSerBufferInfos.target = BufferInfos;
        }
    }
}