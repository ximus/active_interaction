RSpec.describe ActiveInteraction::UnionFilter, :filter do
  include_context 'filters'
  it_behaves_like 'a filter'

  def process(value)
    filter.process(value, nil)
  end

  context 'with multiple primitive-type nested filters' do
    let(:block) do
      proc do
        integer
        string
      end
    end

    it 'accepts either nested filter input' do
      expect(process(123)).to be_sucessful(value: 123)
      expect(process('foo')).to be_sucessful(value: 'foo')
    end

    it 'rejects non-nested filter input' do
      expect(process({})).to have_input_error(:invalid_type)
      expect(process([])).to have_input_error(:invalid_type)
      expect(process(123.4)).to have_input_error(:invalid_type)
      expect(process(Date.today)).to have_input_error(:invalid_type)
      expect(process(true)).to have_input_error(:invalid_type)
    end

    context 'with a nil default value' do
      before do
        options[:default] = nil
      end

      it 'accepts a nil value' do
        expect(process(nil)).to be_sucessful(value: nil)
      end
    end
  end

  context 'with complex nested filters' do
    let(:block) do
      proc do
        hash do
          string :foo
        end
        array do
          integer
        end
      end
    end

    it 'accepts either valid nested filter input' do
      expect(process({ foo: 'bar' }).value).to eq({ 'foo' => 'bar' })
      expect(process([123]).value).to eq([123])
    end

    it 'rejects non-nested filter input' do
      expect(process({ foo: 123 })).to have_input_error(:invalid_type)
      expect(process(['foo'])).to have_input_error(:invalid_type)
    end
  end

  context 'with multiple hash filters' do
    let(:block) do
      proc do
        hash do
          string :foo
        end
        hash do
          string :bar
        end
      end
    end

    it 'accepts either valid nested filter input' do
      expect(process({ bar: 'baz' }).value).to eq({ 'bar' => 'baz' })
    end

    it 'rejects non-nested filter input' do
      expect(process({ foo: 123 })).to have_input_error(:invalid_type)
      expect(process({ bar: true })).to have_input_error(:invalid_type)
    end
  end
end
