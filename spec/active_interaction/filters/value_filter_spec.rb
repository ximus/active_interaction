RSpec.describe ActiveInteraction::ValueFilter, :filter do
  include_context 'filters'

  let(:result) do
    filter.process(value, nil)
  end

  before do
    options[:eq] = 'some value to make shared example group work'
  end

  it_behaves_like 'a filter'

  context ':eq and value match' do
    before do
      options[:eq] = 123
    end

    let(:value) { 123 }

    it 'provides the value' do
      expect(result.value).to eq(123)
    end

    it 'does not have errors' do
      expect(result.errors).to be_empty
    end
  end

  context ":eq and value don't match" do
    before do
      options[:eq] = 123
    end

    let(:value) { 124 }

    it 'provides the value' do
      expect(result.value).to eq(124)
    end

    it 'has an error' do
      expect(result).to have_input_error(:invalid_type)
    end
  end

  context ':eq is missing' do
    before do
      options.delete(:eq)
    end

    let(:value) { 123 }

    it 'throws' do
      expect { result }.to raise_error ActiveInteraction::InvalidFilterError
    end
  end

  context 'symbol :converter is specified' do
    before do
      options[:eq] = 'foo'
      options[:converter] = :downcase
    end

    let(:value) { 'FOO' }

    it 'provides the converted value' do
      expect(result.value).to eq('foo')
    end

    it 'does not have errors' do
      expect(result.errors).to be_empty
    end
  end

  context 'proc :converter is specified' do
    before do
      options[:eq] = 'foo'
      options[:converter] = ->(_v) { 'foo' }
    end

    let(:value) { 'bar' }

    it 'provides the converted value' do
      expect(result.value).to eq('foo')
    end

    it 'does not have errors' do
      expect(result.errors).to be_empty
    end
  end

  context 'bad :converter is specified' do
    before do
      options[:eq] = 'foo'
      options[:converter] = 123
    end

    let(:value) { 'bar' }

    it 'raises an error' do
      expect { result }.to raise_error ActiveInteraction::InvalidConverterError
    end
  end
end
