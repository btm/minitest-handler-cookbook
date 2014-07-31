require_relative '../spec_helper'

describe ::MinitestHandler::CookbookHelper do
  describe '#cookbook_file_names' do
    let(:dummy_class) { Class.new { include ::MinitestHandler::CookbookHelper } }

    before do
      @base_files_path = '/cookbook_path/cookbook_name/files/default'
      Chef::Config[:cookbook_path] = ['/cookbook_path']
    end

    it 'returns relative paths' do
      allow_any_instance_of(dummy_class).to receive(:cookbook_file_paths).and_return(
        [
          ::File.join(@base_files_path, 'tests', 'default_test.rb'),
          ::File.join(@base_files_path, 'test', 'default_test.rb'),
          ::File.join(@base_files_path, 'tests', 'minitest', 'default_test.rb'),
          # Also test variations of relative paths starting at cookbook root
          ::File.join('files', 'default', 'tests', 'minitest', 'default_test.rb'),
          ::File.join('files', 'default', 'test', 'default_test.rb')
        ]
      )
      expect(dummy_class.new.send(:cookbook_file_names, 'cookbook_name')[0]).to eq(
        'tests/default_test.rb')
      expect(dummy_class.new.send(:cookbook_file_names, 'cookbook_name')[1]).to eq(
        'test/default_test.rb')
      expect(dummy_class.new.send(:cookbook_file_names, 'cookbook_name')[2]).to eq(
        'tests/minitest/default_test.rb')
      expect(dummy_class.new.send(:cookbook_file_names, 'cookbook_name')[3]).to eq(
        'tests/minitest/default_test.rb')
      expect(dummy_class.new.send(:cookbook_file_names, 'cookbook_name')[4]).to eq(
        'test/default_test.rb')
    end

    context 'windows' do
      it 'strips windows drive letters' do
        # https://github.com/btm/minitest-handler-cookbook/issues/60#issuecomment-43616036
        allow_any_instance_of(dummy_class).to receive(:cookbook_file_paths).and_return(
          ["C:#{@base_files_path}/tests/default_test.rb"])

        file_path = dummy_class.new.send(:cookbook_file_names, 'cookbook_name').first
        expect(file_path).not_to start_with('C:'),
                                 "'C:' should have been stripped from #{file_path}"
      end
    end
  end
end
