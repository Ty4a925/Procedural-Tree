AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.Spawnable = false

ENT.PrintName = "Procedural Tree"
ENT.Author = "Ty4a"
ENT.Category = "Procedural Trees"
ENT.Instructions = "Do you have any ideas where I can use this?"

ENT.TreeHD = 9
ENT.RENDER_MESH = {}

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "TreeSize")
end

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
        self:PhysicsInit(SOLID_BBOX)

        local phys = self:GetPhysicsObject()

        if phys:IsValid() then
            phys:EnableMotion(false)
        end
    else
        local size = self:GetTreeSize()
        local huhu = 10 * size

        local obbmax, obbmin = Vector(huhu, huhu, huhu * 2.5), Vector(huhu, huhu, 0)
        self:SetRenderBounds(-obbmin, obbmax)

        self.TreeSticks = {}
        self.TreeUP = 1

        local function StickGEN(pos, pos2, gen, len, rad, num)

            if gen <= 0 then return end

            local stick = {
                StartPos = pos,
                --EndPos = pos + pos2 * len,
                Length = len,
                Growth = 0,
                PosTo = pos2,
                Radius = rad,
                Gen = num
            }

            self.TreeSticks[#self.TreeSticks + 1] = stick

            if num < 6 then
                local rand = math.random(2, 4)
                for i = 1, rand do
                    local pos3 = (pos2 + VectorRand() * 0.7):GetNormalized()
                    StickGEN(pos + pos2 * len, pos3, gen - 1, len * 0.7, rad * 0.7, num + 1)
                end
            end

        end
        
        StickGEN(vector_origin, Vector(0, 0, 1), self.TreeHD, 16.5 / 2 * size, 1 / 2 * size, 1)
    end
end

if SERVER then return end

local mat = Material("models/props_foliage/tree_deciduous_01a_trunk")

function ENT:OnRemove()
    if IsValid(self.RENDER_MESH) then
        self.RENDER_MESH:Destroy()
    end
end

function ENT:GetRenderMesh()
    local MESH = {}

    local upping = true

    if self.TreeSticks then
        for i=1, #self.TreeSticks do
            local stick = self.TreeSticks[i]
            if stick.Gen == self.TreeUP then
                local lerp = stick.Growth
                stick.Growth = Lerp(FrameTime() * 45, lerp, 1)

                if lerp < 0.999 then upping = false end
            end

            local startpos = stick.StartPos

            local grownLength = stick.Length * stick.Growth
            local endPos = startpos + stick.PosTo * grownLength

            local xy = stick.Radius / 2

            local base1 = startpos + Vector(-xy, -xy, 0)
            local base2 = startpos + Vector(xy, -xy, 0)
            local base3 = startpos + Vector(xy, xy, 0)
            local base4 = startpos + Vector(-xy, xy, 0)

            local top1 = endPos + Vector(-xy, -xy, 0)
            local top2 = endPos + Vector(xy, -xy, 0)
            local top3 = endPos + Vector(xy, xy, 0)
            local top4 = endPos + Vector(-xy, xy , 0)

            local faces = {
                {base1, base2, top2, top1},
                {base2, base3, top3, top2},
                {base3, base4, top4, top3},
                {base4, base1, top1, top4},
                --{top1, top2, top3, top4},
                --{base1, base2, base3, base4}
            }

            for i = 1, #faces do
                local face = faces[i]
                local face1 = face[1]
                local face2 = face[2]
                local face3 = face[3]
                local face4 = face[4]

                local nm1 = (face3 - face1):GetNormalized()
                local nm2 = (face1 - face3):GetNormalized()
                MESH[#MESH + 1] = { pos = face1, normal = nm1, u = 0, v = 0 }
                MESH[#MESH + 1] = { pos = face2, normal = (face3 - face2):GetNormalized(), u = 1, v = 0 }
                MESH[#MESH + 1] = { pos = face3, normal = nm2, u = 1, v = 1 }

                MESH[#MESH + 1] = { pos = face3, normal = nm2, u = 1, v = 1 }
                MESH[#MESH + 1] = { pos = face4, normal = (face4 - face1):GetNormalized(), u = 0, v = 1 }
                MESH[#MESH + 1] = { pos = face1, normal = nm1, u = 0, v = 0 }
            end
        end

        if upping then
            if self.TreeUP > 6 then

                if IsValid(self.RENDER_MESH) then
                    self.RENDER_MESH:Destroy()
                    self.RENDER_MESH = nil
                end

                self.TreeSticks = nil
            end
            
            self.TreeUP = self.TreeUP + 1
        end

        
        self.RENDER_MESH = Mesh()
        self.RENDER_MESH:BuildFromTriangles(MESH)
    end

    if !self.RENDER_MESH then return end
    return { Mesh = self.RENDER_MESH, Material = mat }
end