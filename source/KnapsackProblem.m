classdef KnapsackProblem
    properties
        individuals_size
        traits
        alleles
    end
    
    methods
        function self = KnapsackProblem(knapsack_capacity, traits)
            self.individuals_size = knapsack_capacity;
            self.traits = traits;
            self.alleles = [0 1];
        end
        
        function get_fitness(self, individual)
            current_value = 0;
            current_cost = 0;
            current_item = 0;
            for gen = individual.genes
                if (gen == 1) && (current_cost + self.traits(current_item) <= self.individuals_size)
                    current_cost = current_cost + self.traits(current_item).cost;
                    current_value = current_value + self.traits(current_item).value;
                end
                current_item = current_item + 1;
                if current_cost == self.individuals_size
                    break
                end
            end
            individual.fitness = current_value;
        end
        
        function decode_individual(self, individual)
        end   
        
    end
end

