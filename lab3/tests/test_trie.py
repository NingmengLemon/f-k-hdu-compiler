from lab3 import Trie


def test_insert():
    trie = Trie("root")
    trie.insert(["c", "a", "t"])
    print("")
    trie.display()
    assert trie.rootNode
    assert (child := trie.rootNode.find_child("c")) is not None
    assert (child := child.find_child("a")) is not None
    assert (child := child.find_child("t")) is not None
    assert child.isEnd is True


def test_get_prefixes():
    trie = Trie("root")
    trie.insert(list("apple"))
    trie.insert(list("apply"))
    trie.insert(list("application"))
    trie.insert(list("ball"))
    trie.insert(list("bat"))
    trie.insert(list("bath"))
    trie.insert(list("Xb"))
    print()
    trie.display()
    prefixes = trie.get_prefixes()
    print(prefixes)
    assert list("appl") in prefixes
    assert list("ba") in prefixes
    assert list("X") not in prefixes
