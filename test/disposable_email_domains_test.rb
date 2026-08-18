# frozen_string_literal: true

require "test_helper"

class DisposableEmailDomainsTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::DisposableEmailDomains::VERSION
  end

  def test_set
    assert_kind_of Set, DisposableEmailDomains.set
    refute_empty DisposableEmailDomains.set

    DisposableEmailDomains.set.each do |domain|
      assert_kind_of String, domain
      refute_match(/[@\s]/, domain)
    end
  end

  def test_include
    DisposableEmailDomains.set.each do |domain|
      p domain
      assert DisposableEmailDomains.include? "bot@#{domain}"
    end

    refute DisposableEmailDomains.include? "legit-person@yahoo.com"
    refute DisposableEmailDomains.include? "someone@gmail.com"
    refute DisposableEmailDomains.include? nil
  end

  def test_domains_ext_included
    assert DisposableEmailDomains.include? "bot@tutanota.com"
    assert DisposableEmailDomains.include? "bot@wwpager.org"
    assert DisposableEmailDomains.include? "bot@wwpager.net"
    assert DisposableEmailDomains.include? "bot@wwpager.me"
    assert DisposableEmailDomains.include? "bot@wwpager.com"
    assert DisposableEmailDomains.include? "bot@wwpager.ru"
    assert DisposableEmailDomains.include? "bot@protonmail.com"
    assert DisposableEmailDomains.include? "bot@proton.me"
  end

  def test_wildcard_matches_apex_domain
    assert DisposableEmailDomains.include? "bot@xwwei.com"
    assert DisposableEmailDomains.include? "bot@yaobba.com"
  end

  def test_wildcard_matches_subdomains
    assert DisposableEmailDomains.include? "bot@mail.xwwei.com"
    assert DisposableEmailDomains.include? "bot@a.b.xwwei.com"
    assert DisposableEmailDomains.include? "bot@mail.yaobba.com"
  end

  def test_wildcard_does_not_match_lookalike_domains
    refute DisposableEmailDomains.include? "bot@notxwwei.com"
    refute DisposableEmailDomains.include? "bot@xwwei.com.attacker.com"
  end

  def test_wildcard_does_not_match_subdomains_of_unlisted_domains
    refute DisposableEmailDomains.include? "someone@mail.gmail.com"
    refute DisposableEmailDomains.include? "someone@mail.yahoo.com"
  end

  def test_wildcard_set
    assert_kind_of Set, DisposableEmailDomains.wildcard_set
    refute_empty DisposableEmailDomains.wildcard_set

    DisposableEmailDomains.wildcard_set.each do |domain|
      refute_match(/[*@\s]/, domain)
      assert_operator domain.count("."), :>=, 1, "#{domain} must have at least two labels"
    end
  end

  def test_wildcard_entries_are_part_of_the_full_set
    assert_operator DisposableEmailDomains.set, :>=, DisposableEmailDomains.wildcard_set
  end
end
