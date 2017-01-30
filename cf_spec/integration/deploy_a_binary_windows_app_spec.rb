require 'spec_helper'

describe 'CF Binary Buildpack' do
  after do
    Machete::CF::DeleteApp.new.execute(app)
  end

  describe 'deploying a Windows batch script' do
    let(:app_name) { 'windows_app' }

    context 'when specifying a buildpack' do
      let(:app) { Machete.deploy_app(app_name, buildpack: 'binary-test-buildpack', stack: 'windows2012R2') }

      it 'deploys successfully' do
        skip_if_no_windows_stack

        expect(app).to be_running

        expect(app).to have_logged("Hello, world!")
      end
    end

    context 'without specifying a buildpack' do
      let(:app) { Machete.deploy_app(app_name, stack: 'windows2012R2') }

      it 'fails to stage' do
        skip_if_no_windows_stack

        expect(app).not_to be_running

        if diego_enabled?(app_name)
          expect(app).to have_logged('None of the buildpacks detected a compatible application')
        else
          expect(app).to have_logged('An app was not successfully detected by any available buildpack')
        end
      end
    end
  end

  def diego_enabled?(app_name)
    `cf has-diego-enabled #{app_name}`.chomp == 'true'
  end

  def skip_if_no_windows_stack
    return if has_windows_stack?

    skip 'cf installation does not have a Windows stack'
  end

  def has_windows_stack?
    `cf stacks`.include? 'windows2012R2'
  end
end