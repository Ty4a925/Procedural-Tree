local scripted_ents = scripted_ents

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.Spawnable = false

local TYPES = {
    1,
    5,
    25,
    100
    --1000
}

for i = 1, #TYPES do
    local TYPE = TYPES[i]

    local ENT = scripted_ents.Get("ent_treemesh")
    ENT.Spawnable = true
    ENT.PrintName =  "Tree: (" .. TYPE .. ")"

    function ENT:SpawnFunction(ply, tr, class)
        local tree = ents.Create("ent_treemesh")
        tree:Spawn()
        tree:SetTreeSize(TYPE)

        timer.Simple(0, function() tree:SetPos(tr.HitPos) end)
        --tree:EmitSound("npc/antlion/digdown1.wav", 100, 175)

        return tree
    end

    scripted_ents.Register(ENT, "ent_treemesh" .. TYPE)
end