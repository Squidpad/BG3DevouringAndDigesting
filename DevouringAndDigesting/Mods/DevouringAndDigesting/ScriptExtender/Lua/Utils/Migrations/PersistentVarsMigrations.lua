---resets missing values in VoreData to default value from VoreDataEntry
---not usable for something more complex
function SP_MigratePersistentVars()
    for k, v in pairs(VoreData) do
        for i, j in pairs(VoreDataEntry) do
            if v[i] == nil then
                _F('Character: ' .. k)
                _F('Missing value: ' .. i)
                if type(j) == "table" then
                    VoreData[k][i] = SP_Deepcopy(j)
                else
                    VoreData[k][i] = j
                end
            end
        end
    end
end