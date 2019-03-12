require "spec_helper"

describe Filters::RadioFilter do
  subject(:radio_filter) {
    Filters::RadioFilter.new(facet, params)
  }

  let(:facet) { double }
  let(:params) { nil }

  describe "#active?" do
    context "when params is nil" do
      it "should be false" do
        expect(radio_filter).not_to be_active
      end
    end

    context "when params is empty" do
      let(:params) { [] }

      it "should be false" do
        expect(radio_filter).not_to be_active
      end
    end
  end

  describe "#key" do
    context "when a filter_key is present" do
      let(:facet) { { "filter_key" => "alpha", "key" => "beta" } }

      it "returns filter_key" do
        expect(radio_filter.key).to eq("alpha")
      end
    end

    context "when a filter_key is not present" do
      let(:facet) { { "key" => "beta" } }

      it "returns key" do
        expect(radio_filter.key).to eq("beta")
      end
    end
  end

  describe "#value" do
    context "when params is present and option_lookup is absent" do
      let(:params) { %w(alpha) }
      let(:facet) { {} }

      it "should contain all values" do
        expect(radio_filter.value).to eq(%w(alpha))
      end
    end

    context "when params is present and option_lookup is empty" do
      let(:params) { %w(does_not_exist) }
      let(:facet) { { "option_lookup" => { "policy_papers" => %w(guidance) } } }

      it "should contain no values" do
        expect(radio_filter.value).to eq([])
      end
    end

    context "when params is present and option_lookup is present" do
      let(:params) { %w(policy_papers) }
      let(:facet) { { "option_lookup" => { "policy_papers" => %w(guidance) } } }

      it "should contain all values" do
        expect(radio_filter.value).to eq(%w(guidance))
      end
    end

    context "when params has multiple values and option_lookup is present" do
      let(:params) { %w(policy_papers does_not_exist consultations) }
      let(:facet) { { "option_lookup" => { "consultations" => %w(open closed), "policy_papers" => %w(guidance) } } }

      it "should contain all values" do
        expect(radio_filter.value).to eq(%w(open closed guidance))
      end
    end
  end
end
