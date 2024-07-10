function ListOption(label, callback)
    local self = {
        ["label"]=label,
        ["callback"]=callback,
        ["highlight"]=false
    }

    function self:click()
        self.highlight = self.callback(self)
    end

    return self
end