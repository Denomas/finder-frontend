class DateFacet < FilterableFacet
  attr_reader :date_values

  def initialize(facet, value_hash)
    @date_values = value_hash || {}
    super(facet)
  end

  def user_supplied_from_date
    date_values["from"]
  end

  def user_supplied_to_date
    date_values["to"]
  end

  def errors_to
    date_errors_presenter.present(user_supplied_to_date)
  end

  def errors_from
    date_errors_presenter.present(user_supplied_from_date)
  end

  def sentence_fragment
    return nil unless has_filters?

    {
      "key" => key,
      "preposition" => [preposition, additional_preposition].compact.join(" "),
      "values" => value_fragments,
      "word_connectors" => and_word_connectors,
    }
  end

  def has_filters?
    present_values.any?
  end

  def query_params
    { key => date_values }
  end

private

  def date_errors_presenter
    DateErrorsPresenter.new(date_values)
  end

  def value_fragments
    present_values.map { |name, date|
      {
        "label" => date.date.strftime("%e %B %Y"),
        "parameter_key" => key,
        "value" => date.original_input,
        "name" => "#{key}[#{name}]",
      }
    }
  end

  def present_values
    parsed_values.select { |_, date|
      date.date.present?
    }
  end

  def parsed_values
    (date_values || {}).reduce({}) { |h, (k, v)|
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
    attr_reader :original_input

    def initialize(date_string)
      @original_input = date_string
    end

    def to_iso8601
      date.iso8601
    end

    def date
      @date ||= DateParser.new.parse(original_input)
    end

    def to_param
      original_input
    end
  end
end
