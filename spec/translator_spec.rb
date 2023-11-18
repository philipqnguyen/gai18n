include OpenAIStubs

describe 'Translator' do
  subject {GAI18n::Translator.new}

  describe '#translate' do
    let(:thread_id) {'thread_LMixmZfcfEV1qu4QJLuDOVk4_1'}
    let(:assistant_id) {'asst_UZHIRZJLxGpJlUus6FUm2F2a'}
    let(:run_id) {'run_TjrVruOUqTMH3KVhXrqJcazi_1'}
    let!(:post_thread) {post_thread_stub thread_ids: [thread_id]}
    let!(:post_message) {post_message_stub thread_id: thread_id, untranslated_keys_values: untranslated_keys_values}
    let!(:post_run) do
      post_run_stub run_id: run_id,
                    thread_id: thread_id,
                    assistant_id: assistant_id
    end
    let!(:get_run_1) do
      get_run_in_progress_stub thread_id: thread_id,
                               assistant_id: assistant_id,
                               run_id: run_id
    end
    let!(:get_run_2) do
      get_run_requires_action_stub thread_id: thread_id,
                                   assistant_id: assistant_id,
                                   run_id: run_id,
                                   translated_keys_values: translated_keys_values
    end
    let!(:post_submit_tool_output) do
      post_submit_tool_output_stub assistant_id: assistant_id, thread_id: thread_id, run_id: run_id, translated_keys_values: translated_keys_values
    end
    let(:tmp_dir) { FileUtils.mkdir_p("#{GAI18n.config.project_root}/tmp") }
    let(:locales_dir) { Dir.mktmpdir(nil, tmp_dir) }
    let(:changed_keys) { [] }

    def copy_fixture_file_to_temp_locales_dir(lang)
      path = "#{GAI18n.config.project_root}/spec/support/#{lang}.yml"
      FileUtils.cp(path, "#{locales_dir}/#{lang}.yml")
    end

    before do
      copy_fixture_file_to_temp_locales_dir('en')
      copy_fixture_file_to_temp_locales_dir('jp')
      allow_any_instance_of(GAI18n::GitComparison).to receive(:changes).and_return(changed_keys)
      GAI18n.configure do |config|
        config.source_locale = {
          english: {
            files: "#{locales_dir}/en.yml",
            file_identifier: 'en',
            root_key: 'en'
          }
        }
        config.target_locales = {
          japanese: {
            file_identifier: 'jp',
            root_key: 'jp'
          }
        }
        config.openai_secret_key = "fake_secret"
        config.openai_assistant_id = assistant_id
      end
    end

    after do
      FileUtils.rm_rf(tmp_dir)
    end

    context 'given source file had keys removed (signout) and added (create, update, delete)' do
      let(:untranslated_keys_values) { {'actions.create' => 'Create', 'actions.update' => 'Update', 'actions.delete' => 'Delete'}  }
      let(:translated_keys_values) { {'actions.create' => '作成', 'actions.update' => '更新', 'actions.delete' => '削除'}  }

      before do
        edited_content = {
          'en' => {
            'about' => {
              'title' => 'About Us'
            },
            'actions' => {
              'signin' => 'Sign In',
              'create' => 'Create',
              'update' => 'Update',
              'delete' => 'Delete',
              'back' => 'Back'
            }
          }
        }
        source_file = File.new("#{locales_dir}/en.yml", 'w+')
        source_file.write(edited_content.to_yaml)
        source_file.close
        subject.translate
      end

      it 'should maintain key order' do
        content = YAML.load_file("#{locales_dir}/jp.yml")
        expect(content['jp'].keys).to eq(['about', 'actions'])
        expect(content['jp']['actions'].keys).to eq(['signin', 'create', 'update', 'delete', 'back'])
      end

      it 'should output file with content matching expected content' do
        content = YAML.load_file("#{locales_dir}/jp.yml")
        expect(content).to eq(
          {
            'jp' => {
              'about' => {
                'title' => '私たちについて'
              },
              'actions' => {
                'signin' => 'サインイン',
                'create' => '作成',
                'update' => '更新',
                'delete' => '削除',
                'back' => '戻る'
              }
            }
          }
        )
      end
    end

    context 'given source file only has removed keys (signout)' do
      let(:untranslated_keys_values) { {}  }
      let(:translated_keys_values) { {}  }

      before do
        edited_content = {
          'en' => {
            'about' => {
              'title' => 'About Us'
            },
            'actions' => {
              'signin' => 'Sign in',
              'back' => 'Back'
            }
          }
        }
        source_file = File.new("#{locales_dir}/en.yml", 'w+')
        source_file.write(edited_content.to_yaml)
        source_file.close
        subject.translate
      end

      it 'should maintain key order' do
        content = YAML.load_file("#{locales_dir}/jp.yml")
        expect(content['jp'].keys).to eq(['about', 'actions'])
        expect(content['jp']['actions'].keys).to eq(['signin', 'back'])
      end

      it 'should output file with content matching expected content' do
        content = YAML.load_file("#{locales_dir}/jp.yml")
        expect(content).to eq(
          {
            'jp' => {
              'about' => {
                'title' => '私たちについて'
              },
              'actions' => {
                'signin' => 'サインイン',
                'back' => '戻る'
              }
            }
          }
        )
      end
    end

    context 'given the source file has a key (about.title) whose value was changed' do
      let(:changed_keys) { ['about.title'] }
      let(:untranslated_keys_values) { {'about.title' => 'About Our Company'} }
      let(:translated_keys_values) { {'about.title' => '当社について'} }

      before do
        edited_content = {
          'en' => {
            'about' => {
              'title' => 'About Our Company'
            },
            'actions' => {
              'signin' => 'Sign In',
              'signout' => 'Sign Out',
              'back' => 'Back'
            }
          }
        }
        source_file = File.new("#{locales_dir}/en.yml", 'w+')
        source_file.write(edited_content.to_yaml)
        source_file.close
        subject.translate
      end

      it 'should maintain key order' do
        content = YAML.load_file("#{locales_dir}/jp.yml")
        expect(content['jp'].keys).to eq(['about', 'actions'])
        expect(content['jp']['actions'].keys).to eq(['signin', 'signout', 'back'])
      end

      it 'should output file with content matching expected content' do
        content = YAML.load_file("#{locales_dir}/jp.yml")
        expect(content).to eq(
          {
            'jp' => {
              'about' => {
                'title' => '当社について'
              },
              'actions' => {
                'signin' => 'サインイン',
                'signout' => 'サインアウト',
                'back' => '戻る'
              }
            }
          }
        )
      end
    end

    context 'given the target file does not exist' do
      let(:changed_keys) { [] }
      let(:untranslated_keys_values) do
        {
          'about.title' => 'About Us',
          'actions.signin' => 'Sign in',
          'actions.signout' => 'Sign out',
          'actions.back' => 'Back'
        }
      end
      let(:translated_keys_values) do
        {
          'about.title' => '私たちについて',
          'actions.signin' => 'サインイン',
          'actions.signout' => 'サインアウト',
          'actions.back' => '戻る'
        }
      end

      before do
        FileUtils.rm("#{locales_dir}/jp.yml")
        subject.translate
      end

      it 'should maintain key order' do
        content = YAML.load_file("#{locales_dir}/jp.yml")
        expect(content['jp'].keys).to eq(['about', 'actions'])
        expect(content['jp']['actions'].keys).to eq(['signin', 'signout', 'back'])
      end

      it 'should output file with content matching expected content' do
        content = YAML.load_file("#{locales_dir}/jp.yml")
        expect(content).to eq(
          {
            'jp' => {
              'about' => {
                'title' => '私たちについて'
              },
              'actions' => {
                'signin' => 'サインイン',
                'signout' => 'サインアウト',
                'back' => '戻る'
              }
            }
          }
        )
      end
    end

    context 'given the target file is empty' do
      let(:changed_keys) { [] }
      let(:untranslated_keys_values) do
        {
          'about.title' => 'About Us',
          'actions.signin' => 'Sign in',
          'actions.signout' => 'Sign out',
          'actions.back' => 'Back'
        }
      end
      let(:translated_keys_values) do
        {
          'about.title' => '私たちについて',
          'actions.signin' => 'サインイン',
          'actions.signout' => 'サインアウト',
          'actions.back' => '戻る'
        }
      end

      before do
        File.write("#{locales_dir}/jp.yml", '')
        subject.translate
      end

      it 'should maintain key order' do
        content = YAML.load_file("#{locales_dir}/jp.yml")
        expect(content['jp'].keys).to eq(['about', 'actions'])
        expect(content['jp']['actions'].keys).to eq(['signin', 'signout', 'back'])
      end

      it 'should output file with content matching expected content' do
        content = YAML.load_file("#{locales_dir}/jp.yml")
        expect(content).to eq(
          {
            'jp' => {
              'about' => {
                'title' => '私たちについて'
              },
              'actions' => {
                'signin' => 'サインイン',
                'signout' => 'サインアウト',
                'back' => '戻る'
              }
            }
          }
        )
      end
    end

    context 'given paginated requests are needed' do
      let(:thread_id_2) {'thread_LMixmZfcfEV1qu4QJLuDOVk4_2'}
      let(:run_id_2) {'run_TjrVruOUqTMH3KVhXrqJcazi_2'}
      let!(:post_thread) {post_thread_stub thread_ids: [thread_id, thread_id_2]}
      let!(:post_message_2) {post_message_stub thread_id: thread_id_2, untranslated_keys_values: untranslated_keys_values_2}
      let!(:post_run_2) do
        post_run_stub run_id: run_id_2,
                      thread_id: thread_id_2,
                      assistant_id: assistant_id
      end
      let!(:get_run_1_2) do
        get_run_in_progress_stub thread_id: thread_id_2,
                                 assistant_id: assistant_id,
                                 run_id: run_id_2
      end
      let!(:get_run_2_2) do
        get_run_requires_action_stub thread_id: thread_id_2,
                                     assistant_id: assistant_id,
                                     run_id: run_id_2,
                                     translated_keys_values: translated_keys_values_2
      end
      let!(:post_submit_tool_output_2) do
        post_submit_tool_output_stub assistant_id: assistant_id, thread_id: thread_id_2, run_id: run_id_2, translated_keys_values: translated_keys_values_2
      end
      let(:changed_keys) { [] }
      let(:untranslated_keys_values) do
        {
          'additional.h1' => 'Hello',
          'additional.h2' => 'Welcome',
        }
      end
      let(:untranslated_keys_values_2) do
        {
          'additional.p' => 'This is a paragraph',
          'additional.a' => 'Click here',
        }
      end
      let(:translated_keys_values) do
        {
          'additional.h1' => 'こんにちは',
          'additional.h2' => 'ようこそ',
        }
      end
      let(:translated_keys_values_2) do
        {
          'additional.p' => 'これは段落です',
          'additional.a' => 'ここをクリック',
        }
      end

      before do
        GAI18n.configure do |config|
          config.keys_per_paginated_requests = 2
        end

        edited_content = {
          'en' => {
            'about' => {
              'title' => 'About Us'
            },
            'actions' => {
              'signin' => 'Sign In',
              'signout' => 'Sign Out',
              'back' => 'Back',
            },
            'additional' => {
              'h1' => 'Hello',
              'h2' => 'Welcome',
              'p' => 'This is a paragraph',
              'a' => 'Click here'
            }
          }
        }
        source_file = File.new("#{locales_dir}/en.yml", 'w+')
        source_file.write(edited_content.to_yaml)
        source_file.close
        subject.translate
      end

      it 'should maintain key order' do
        content = YAML.load_file("#{locales_dir}/jp.yml")
        expect(content['jp'].keys).to eq(['about', 'actions', 'additional'])
        expect(content['jp']['additional'].keys).to eq(['h1', 'h2', 'p', 'a'])
      end

      it 'should output file with content matching expected content' do
        content = YAML.load_file("#{locales_dir}/jp.yml")
        expect(content).to eq(
          {
            'jp' => {
              'about' => {
                'title' => '私たちについて'
              },
              'actions' => {
                'signin' => 'サインイン',
                'signout' => 'サインアウト',
                'back' => '戻る'
              },
              'additional' => {
                'h1' => 'こんにちは',
                'h2' => 'ようこそ',
                'p' => 'これは段落です',
                'a' => 'ここをクリック'
              }
            }
          }
        )
      end
    end
  end
end
