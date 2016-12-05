classdef Item
    properties
        value
        cost
        ratio
    end
    
    methods
        function item = Item(value, cost)
            item.value = value;
            item.cost = cost;
            item.ratio = value / cost;
        end
    end
end

