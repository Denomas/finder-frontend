module Registries
  NAMESPACE = "registries".freeze

  class BaseRegistries
    def all
      @all ||= {
        "world_locations" => world_locations,
        "all_part_of_taxonomy_tree" => full_topic_taxonomy,
        "part_of_taxonomy_tree" => topic_taxonomy,
        "people" => people,
        "roles" => roles,
        "organisations" => organisations,
        "manual" => manuals,
        "full_topic_taxonomy" => full_topic_taxonomy,
      }
    end

    def ensure_warm_cache
      all.each_value.select(&:can_refresh_cache?).each(&:fetch_from_cache)
    end

    def refresh_cache
      all.each_value.select(&:can_refresh_cache?).each(&:refresh_cache)
    end

  private

    def full_topic_taxonomy
      @full_topic_taxonomy ||= FullTopicTaxonomyRegistry.new
    end

    def world_locations
      @world_locations ||= WorldLocationsRegistry.new
    end

    def topic_taxonomy
      @topic_taxonomy ||= TopicTaxonomyRegistry.new
    end

    def people
      @people ||= PeopleRegistry.new
    end

    def roles
      @roles ||= RolesRegistry.new
    end

    def organisations
      @organisations ||= OrganisationsRegistry.new
    end

    def manuals
      @manuals ||= ManualsRegistry.new
    end
  end
end
