require "test_helper"

class RepositoryTest < ActiveSupport::TestCase
  test "valid repository" do
    repository = repositories(:one)

    assert { repository.valid? }
  end

  test "belongs to user" do
    repository = repositories(:one)

    assert { repository.user == users(:one) }
  end

  test "requires user" do
    repository = repositories(:one)
    repository.user = nil

    assert { !repository.valid? }
    assert { repository.errors[:user].any? }
  end

  test "requires attributes" do
    attributes = %i[
      name
      github_id
      full_name
      clone_url
      ssh_url
    ]

    attributes.each do |attribute|
      repository = repositories(:one).dup
      repository[attribute] = nil

      assert { !repository.valid? }
      assert { repository.errors[attribute].any? }
    end
  end

  test "allows ruby language" do
    repository = repositories(:one)
    repository.language = :ruby

    assert { repository.valid? }
    assert { repository.language.ruby? }
  end

  test "does not allow unsupported language" do
    repository = repositories(:one)
    repository.language = :python

    assert { !repository.valid? }
    assert { repository.errors[:language].any? }
  end

  test "has ruby in supported languages" do
    assert { Repository.language.values == [ "ruby", "javascript" ] }
  end

  test "github id must be unique for user" do
    repository = repositories(:one)

    duplicate = repository.dup

    assert { !duplicate.valid? }
    assert { duplicate.errors[:github_id].any? }
  end

  test "different users can add same github repository" do
    repository = repositories(:one).dup
    repository.user = users(:two)

    assert { repository.valid? }
  end
end
