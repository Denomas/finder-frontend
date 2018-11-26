require_relative '../../spec/support/fixtures_helper'

module QAHelper
  include FixturesHelper
    
  def stub_qa_config
    allow_any_instance_of(QaController).to receive(:qa_config).and_return(mock_qa_config)
  end

  def qa_path
    '/prepare-business-uk-leaving-eu'
  end

  def mock_qa_config
    @config ||= YAML.load_file('./features/fixtures/aaib_reports_qa.yaml')
  end

  def first_question
    mock_qa_config["pages"].values.first['question']
  end

  def get_question_by_type(type)
    mock_qa_config["pages"].select do |key, value|
      value["question_type"] == type
    end.values.first['question']
  end

  def get_page_number(question)
    mock_qa_config["pages"].each_with_index do |(key, value), index|
      return index + 1 if value["question"] == question
    end
  end 
  
  def facets
    @facets ||= aaib_reports_content_item["details"]["facets"].select do |facet|
      facet["type"] == "text" && facet["filterable"] && mock_qa_config["pages"][facet["key"]]["show_in_qa"]
    end
  end
end

World(QAHelper) 