--Register trees
local scales = {
    1,
    5,
    25,
    100
}

for i = 1, #scales do
    local scale = scales[i]

    local ENT = {}
    ENT.Base = "ent_treemesh"
    ENT.Spawnable = true
    ENT.PrintName =  "Tree: (" .. scale .. ")"
    ENT.Author = "Ty4a"
    ENT.Category = "Procedural Trees"
    ENT.Instructions = "Do you have any ideas where I can use this?"

    function ENT:SpawnFunction(ply, tr, class)
        local tree = ents.Create("ent_treemesh")
        tree:SetTreeSize(scale)
        tree:SetPos(tr.HitPos)
        tree:Spawn()

        return tree
    end

    scripted_ents.Register(ENT, "ent_treemesh" .. scale)
end