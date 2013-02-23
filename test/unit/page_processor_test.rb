require "test/unit"
require "app/helpers/page_processor"

class PageProcessorTest < Test::Unit::TestCase

  def setup
    @instance = PageProcessor.new
  end

  def test_replace_delimiters
    str = "abc.xyz\ndef\tpdq/lmnop:qrs?tuv-wx~yz"

    actual = @instance.replace_delimiters str

    assert_equal("abc xyz def pdq lmnop qrs tuv wx yz", actual)
  end

  def test_replace_tags

    str = "<xml>fun<x>as</x><y><z>a </z><w>barrel </w></y>full of monkeys</xml>"

    actual = @instance.replace_tags str

    assert_equal("fun as a barrel full of monkeys", actual)

  end

  def test_tokenize

    str = "<xml>fun<x>as</x><y><z>a~</z><w> barrel!</w></y>full%of$monkeys</xml>"

    actual = @instance.tokenize str

    assert_equal("fun", actual[0])
    assert_equal("as", actual[1])
    assert_equal("a", actual[2])
    assert_equal("barrel", actual[3])
    assert_equal("full", actual[4])
    assert_equal("of", actual[5])
    assert_equal("monkeys", actual[6])

  end

  def test_process_page

    romans5 = """5 Therefore being justified by faith, we have peace with God through our Lord Jesus Christ:
              2 By whom also we have access by faith into this grace wherein we stand, and rejoice in hope of the glory of God.
              3 And not only so, but we glory in tribulations also: knowing that tribulation worketh patience;
              4 And patience, experience; and experience, hope:
              5 And hope maketh not ashamed; because the love of God is shed abroad in our hearts by the Holy Ghost which is given unto us.
              6 For when we were yet without strength, in due time Christ died for the ungodly.
              7 For scarcely for a righteous man will one die: yet peradventure for a good man some would even dare to die.
              8 But God commendeth his love toward us, in that, while we were yet sinners, Christ died for us.
              9 Much more then, being now justified by his blood, we shall be saved from wrath through him.
              10 For if, when we were enemies, we were reconciled to God by the death of his Son, much more, being reconciled, we shall be saved by his life.
              11 And not only so, but we also joy in God through our Lord Jesus Christ, by whom we have now received the atonement.
              12 Wherefore, as by one man sin entered into the world, and death by sin; and so death passed upon all men, for that all have sinned:
              13 (For until the law sin was in the world: but sin is not imputed when there is no law.
              14 Nevertheless death reigned from Adam to Moses, even over them that had not sinned after the similitude of Adam's transgression, who is the figure of him that was to come.
              15 But not as the offence, so also is the free gift. For if through the offence of one many be dead, much more the grace of God, and the gift by grace, which is by one man, Jesus Christ, hath abounded unto many.
              16 And not as it was by one that sinned, so is the gift: for the judgment was by one to condemnation, but the free gift is of many offences unto justification.
              17 For if by one man's offence death reigned by one; much more they which receive abundance of grace and of the gift of righteousness shall reign in life by one, Jesus Christ.)
              18 Therefore as by the offence of one judgment came upon all men to condemnation; even so by the righteousness of one the free gift came upon all men unto justification of life.
              19 For as by one man's disobedience many were made sinners, so by the obedience of one shall many be made righteous.
              20 Moreover the law entered, that the offence might abound. But where sin abounded, grace did much more abound:
              21 That as sin hath reigned unto death, even so might grace reign through righteousness unto eternal life by Jesus Christ our Lord."""

    actual = @instance.process_page(romans5)

    assert_equal(190, actual.size)

    assert_equal(actual["justification"], 2)
    assert_equal(actual["hope"], 3)
    assert_equal(actual["were"], 5)
    assert_equal(actual["condemnation"], 1)

  end

end