classdef ArrayHandler < handle
    properties
        x
    end
    
    methods
        function myfunc(obj)
            obj.x = obj.x + 1;
        end
    end
    
end

