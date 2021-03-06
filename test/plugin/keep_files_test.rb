require "test_helper"
require "shrine/plugins/keep_files"

describe Shrine::Plugins::KeepFiles do
  describe ":destroyed" do
    before do
      @attacher = attacher do
        plugin :keep_files, destroyed: true
      end
    end

    it "keeps files which are deleted on destroy" do
      @attacher.set(@attacher.store!(fakeio))
      @attacher.destroy
      assert @attacher.get.exists?
    end
  end

  describe ":replaced" do
    before do
      @attacher = attacher do
        plugin :keep_files, replaced: true
      end
    end

    it "keeps files which were replaced during saving" do
      @attacher.set(uploaded_file = @attacher.store!(fakeio))
      @attacher.set(@attacher.store!(fakeio))
      @attacher.replace
      assert uploaded_file.exists?

      uploaded_file = @attacher.get
      @attacher.assign(nil)
      @attacher.replace
      assert uploaded_file.exists?
    end
  end

  it "works with backgrounding plugin" do
    @attacher = attacher do
      plugin :keep_files, destroyed: true, replaced: true
      plugin :backgrounding
    end

    @attacher.class.delete { |data| fail }
    @attacher.set(replaced = @attacher.store!(fakeio))
    @attacher.set(destroyed = @attacher.store!(fakeio))
    @attacher.replace
    @attacher.destroy
    assert replaced.exists?
    assert destroyed.exists?
  end
end
