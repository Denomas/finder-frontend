class DateFacet < Facet
  def value
    serialized_values.join(",")
  end

  def sentence_fragment
    return nil unless present_values.any?

    OpenStruct.new(
      preposition: [preposition, additional_preposition].compact.join(' '),
      values: value_fragments,
    )
  end

private
  def value_fragments
    present_values.map { |k, date|
      OpenStruct.new(
        label: date.date.strftime("%e %B %Y"),
        parameter_key: key,
        other_params: present_values.reject { |key, _| key == k }
      )
    }
  end

  def serialized_values
    present_values.map { |key, date|
      "#{key}:#{date.to_iso8601}"
    }
  end

  def present_values
    parsed_values.select { |_, date|
      date.date.present?
    }
  end

  def parsed_values
    (@value || {}).reduce({}) { |h, (k, v)|
      h.merge(k => safe_date_parse(v))
    }
  end

  def safe_date_parse(date_string)
    DateInput.new(date_string) rescue nil
  end

  def additional_preposition
    if present_values.length == 2
      "between"
    else
      present_values.map { |k, _|
        preposition_mappings[k]
      }.first
    end
  end

  def preposition_mappings
    {
      "from" => "after",
      "to" => "before",
    }.with_indifferent_access
  end

  class DateInput
    attr_reader :original_input, :date

    def initialize(date_string)
      @original_input = date_string
    end

    def to_iso8601
      date.iso8601
    end

    def date
      @date ||= Date.parse(original_input) rescue nil
    end

    def to_param
      original_input
    end
  end
end