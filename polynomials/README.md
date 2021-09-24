# Trello association

- LFSR analysis [#1](https://github.com/robotique-ecam/ViveTracker/pull/1): [Trello card](https://trello.com/c/qXQqgrRR/17-analyse-polyn%C3%B4me-lfsr)

# Polynomials/Channel association

|Mode|Polynomial 1|Polynomial 2|Rotor frequency|
|-|-|-|-|
|1|`0x1D258`|`0x17E04`|50.052|
|2|`0x1FF6B`|`0x13F67`|50.157|
|3|`0x1B9EE`|`0x198D1`|50.367|
|4|`0x178C7`|`0x18A55`|50.580|
|5|`0x15777`|`0x1D911`|50.686|
|6|`0x15769`|`0x1991F`|50.901|
|7|`0x12BD0`|`0x1CF73`|51.010|
|8|`0x1365D`|`0x197F5`|51.118|
|9|`0x194A0`|`0x1B279`|51.227|
|10|`0x13A34`|`0x1AE41`|51.668|
|11|`0x180D4`|`0x17891`|52.231|
|12|`0x12E64`|`0x17C72`|52.689|
|13|`0x19C6D`|`0x13F32`|52.922|
|14|`0x1AE14`|`0x14E76`|53.274|
|15|`0x13C97`|`0x130CB`|53.751|
|16|`0x13750`|`0x1CB8D`|54.115|

# Unicity of polynomials values

Results according to [*polynomials_validation.py*](https://github.com/robotique-ecam/ViveTracker/blob/c541da06227adf35faff673f2adf5cedfb97fe1c/polynomials/polynomials_validation.py)

```
Results:

Mode 1:
    Same value of polynomial 0x1D258:
        1 at index 0 and 131071
        2 at index 1 and 131072

    Same value of polynomial 0x17e04:
        1 at index 0 and 131071
        2 at index 1 and 131072


Mode2:
    Same value of polynomial 0x1ff6b:
        1 at index 0 and 131071
        3 at index 1 and 131072

    Same value of polynomial 0x13f67:
        1 at index 0 and 131071
        3 at index 1 and 131072


Mode3:
    Same value of polynomial 0x1b9ee:
        1 at index 0 and 131071
        2 at index 1 and 131072

    Same value of polynomial 0x198d1:
        1 at index 0 and 131071
        3 at index 1 and 131072


Mode4:
    Same value of polynomial 0x178c7:
        1 at index 0 and 131071
        3 at index 1 and 131072

    Same value of polynomial 0x18a55:
        1 at index 0 and 131071
        3 at index 1 and 131072


Mode5:
    Same value of polynomial 0x15777:
        1 at index 0 and 131071
        3 at index 1 and 131072

    Same value of polynomial 0x1d911:
        1 at index 0 and 131071
        3 at index 1 and 131072


Mode6:
    Same value of polynomial 0x15769:
        1 at index 0 and 131071
        3 at index 1 and 131072

    Same value of polynomial 0x1991f:
        1 at index 0 and 131071
        3 at index 1 and 131072


Mode7:
    Same value of polynomial 0x12bd0:
        1 at index 0 and 131071
        2 at index 1 and 131072

    Same value of polynomial 0x1cf73:
        1 at index 0 and 131071
        3 at index 1 and 131072


Mode8:
    Same value of polynomial 0x1365d:
        1 at index 0 and 131071
        3 at index 1 and 131072

    Same value of polynomial 0x197f5:
        1 at index 0 and 131071
        3 at index 1 and 131072


Mode9:
    Same value of polynomial 0x194a0:
        1 at index 0 and 131071
        2 at index 1 and 131072

    Same value of polynomial 0x1b279:
        1 at index 0 and 131071
        3 at index 1 and 131072


Mode10:
    Same value of polynomial 0x13a34:
        1 at index 0 and 131071
        2 at index 1 and 131072

    Same value of polynomial 0x1ae41:
        1 at index 0 and 131071
        3 at index 1 and 131072


Mode11:
    Same value of polynomial 0x180d4:
        1 at index 0 and 131071
        2 at index 1 and 131072

    Same value of polynomial 0x17891:
        1 at index 0 and 131071
        3 at index 1 and 131072


Mode12:
    Same value of polynomial 0x12e64:
        1 at index 0 and 131071
        2 at index 1 and 131072

    Same value of polynomial 0x17c72:
        1 at index 0 and 131071
        2 at index 1 and 131072


Mode13:
    Same value of polynomial 0x19c6d:
        1 at index 0 and 131071
        3 at index 1 and 131072

    Same value of polynomial 0x13f32:
        1 at index 0 and 131071
        2 at index 1 and 131072


Mode14:
    Same value of polynomial 0x1ae14:
        1 at index 0 and 131071
        2 at index 1 and 131072

    Same value of polynomial 0x14e76:
        1 at index 0 and 131071
        2 at index 1 and 131072


Mode15:
    Same value of polynomial 0x13c97:
        1 at index 0 and 131071
        3 at index 1 and 131072

    Same value of polynomial 0x130cb:
        1 at index 0 and 131071
        3 at index 1 and 131072


Mode16:
    Same value of polynomial 0x13750:
        1 at index 0 and 131071
        2 at index 1 and 131072

    Same value of polynomial 0x1cb8d:
        1 at index 0 and 131071
        3 at index 1 and 131072
```