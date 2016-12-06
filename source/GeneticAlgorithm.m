classdef GeneticAlgorithm
    properties
        individuals_number
        genes_number
        generations_number
        termination_type
        initialization_type
        parents_selection_type
        tournament_size
        crossover_type
        crossover_rate
        crossover_points_number
        mutation_type
        mutation_rate
        survivor_selection_type
        elitism
                
        problem
        best_individual
        population
        mating_pool
        offspring
        current_generation
    end
    methods
        function self = GeneticAlgorithm(problem)
            properties = ini2struct('algorithm.ini');
            
            self.individuals_number = str2double(...
                properties.individualsnumber);
            self.generations_number = str2double(...
                properties.generationsnumber);
            self.termination_type = str2double(...
                properties.terminationconditiontype);
            self.initialization_type = str2double(...
                properties.initializationtype);
            self.parents_selection_type = str2double(...
                properties.parentselectiontype);
            self.crossover_points_number = str2double(...
                properties.crossoverpointsnumber);
            self.survivor_selection_type = str2double(...
                properties.survivorselectiontype);
            self.genes_number = str2double(properties.genesnumber);
            self.tournament_size = str2double(properties.tournamentsize);
            self.crossover_type = str2double(properties.crossovertype);
            self.crossover_rate = str2double(properties.crossoverrate);
            self.mutation_type = str2double(properties.mutationtype);
            self.mutation_rate = str2double(properties.mutationrate);
            self.elitism = str2double(properties.elitism);
        
            self.problem = problem;
            self.best_individual = Individual(problem.individuals_size);
            self.population = Individual(...
                problem.individuals_size).empty(self.individuals_number, 0);
            self.mating_pool = Individual(...
                problem.individuals_size).empty(self.individuals_number, 0);
            self.offspring = Individual(...
                problem.individuals_size).empty(self.individuals_number, 0);
            self.current_generation = 0;
            
            if mod(self.individuals_number, 2) ~= 0
                error('[!] "IndividualsNumber" property value must be even.')
            end
        end
        
        function run(self)
            tic;
            
            self.population = self.initialize();
            self.population = self.evaluate(self.problem, self.population);
            %while termination_condition() ~= 1
            %    select_parents()
            %    recombine()
            %    mutate()
            %    evaluate(self.problem, self.offspring)
            %    survivor_selection()

            %    self.current_generation = self.current_generation + 1;
            %    self.offspring =...
            %        Individual(self.problem.individuals_size).empty(...
            %       self.individuals_number, 0);
            %end
            
            toc;
        end
        
        function population = initialize(self)
            if self.initialization_type == 1
                population = self.random_initialization(...
                                           self.individuals_number,...
                                           self.problem.alleles,...
                                           self.population,...
                                           self.genes_number);
            else
                error('[!] Value {} ".format(self.initialization_type)'...
                         + 'specified by "InitializationType" property '...
                         + 'does not mach with any initialization type')
            end
        end
        
        function population = random_initialization(~, individuals_number,...
                                       alleles, population, genes_number)
            for i = 1:individuals_number
                individual = Individual(genes_number);
                for j = 1:genes_number
                    allele = alleles(randperm(numel(alleles), 1));
                    individual.genes(j) = allele;
                end
                population(i) = individual;
            end
        end
        
        function individuals = evaluate(~, problem, individuals)
            for i = 1:numel(individuals)
                individuals(i).fitness = problem.get_fitness(individuals(i));
            end
            [~, sort_order] = sort([individuals.fitness], 'descend');
            individuals = individuals(sort_order);
        end
        
        function finish = termination_condition(self)
            if self.termination_type == 1
                finish = self.generations_number_condition(...
                                        self.generations_number,...
                                        self.current_generation);
            elseif self.termination_type == 2
                finish = self.fitness_repetition(self.best_individual,...
                                                 self.generations_number);
            end
        end
        
        function finish = generations_number_condition(~)
            
        end
        
        
        
    end
    
end

