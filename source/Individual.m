classdef Individual
    properties
        fitness = -1
        age = 0
        genes
    end
    methods
        function self = Individual(genes_number)
            self.genes = zeros(genes_number);
        end
    end
end

