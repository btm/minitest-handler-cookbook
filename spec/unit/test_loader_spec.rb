require_relative '../spec_helper'

describe ::MinitestHandler::CookbookHelper do
  describe '#cookbook_file_names' do
    let(:dummy_class) { Class.new { include ::MinitestHandler::CookbookHelper } }

    before do
      @base_files_path = '/cookbook_path/cookbook_name/files/default'
      Chef::Config[:cookbook_path] = ['/cookbook_path']

    end
    context 'windows' do
      it 'strips windows drive letters' do
        # https://github.com/btm/minitest-handler-cookbook/issues/60#issuecomment-43616036
        dummy_class.any_instance.stub_chain(
          :run_context, :cookbook_collection, :[], :file_filenames
        ).and_return(
          ["C:#{@base_files_path}/tests/default_test.rb"]
        )
        file_path = dummy_class.new.send(:cookbook_file_names, 'cookbook_name').first
        expect(file_path).not_to start_with('C:'),
                                 "'C:' should have been stripped from #{file_path}"
      end
    end
  end
end
