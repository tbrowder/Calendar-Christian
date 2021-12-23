unit class Date::Liturgical::Christian::Feasts;

our constant %feasts-UMC is export = [
    # Derived from the original ECUSA %feasts, from UMC documents,
    # and assistance from the Reverend Pam Avery.

    # Dates relative to Easter are encoded as the number of
    # days after Easter.

    # Principal Feasts (precedence is 9)
    0  => { name => 'Easter', prec=>9 },
    39 => { name => 'Ascension', prec=>9 },
    49 => { name => 'Pentecost', color => 'red', prec=>9 },
    56 => { name => 'Trinity', prec=>9 },

    # And others:
    -46 => { name => 'Ash Wednesday', color=>'purple', prec=>7 },
    # is the color of Shrove Tuesday right?
    -47 => { name => 'Shrove Tuesday', color=>'white', prec=>7 },
    # Actually, Easter Eve doesn't have a color
    -1 => { name => 'Easter Eve', color=>'purple', prec=>7 },
    -2 => { name => 'Good Friday', color=>'purple', prec=>7 },

    # Dates relative to Christmas are encoded as 10000 + 100*m + d
    # for simplicity.

    # Principal Feasts (precedence is 9)

    10106 => {name=>'Epiphany', prec=>9},
    11101 => {name=>'All Saints', prec=>9},
    11225 => {name=>'Christmas', prec=>9},

    # Days which can take priority over Sundays (precedence is 7)

    10101 => {name=>'Holy Name', prec=>7},
    10202 => {name=>'Presentation of our Lord', prec=>7},
    10806 => {name=>'Transfiguration', prec=>7},

    # (Precendence of Sundays is 5)

];

our constant %feasts-ECUSA is export = [

    # Dates relative to Easter are encoded as the number of
    # days after Easter.

    # Principal Feasts (precedence is 9)
    0  => { name => 'Easter', prec=>9 },
    39 => { name => 'Ascension', prec=>9 },
    49 => { name => 'Pentecost', color => 'red', prec=>9 },
    56 => { name => 'Trinity', prec=>9 },

    # And others:
    -46 => { name => 'Ash Wednesday', color=>'purple', prec=>7 },
    # is the color of Shrove Tuesday right?
    -47 => { name => 'Shrove Tuesday', color=>'white', prec=>7 },
    # Actually, Easter Eve doesn't have a color
    -1 => { name => 'Easter Eve', color=>'purple', prec=>7 },
    -2 => { name => 'Good Friday', color=>'purple', prec=>7 },

    50 => { name => 'Book of Common Prayer', prec=>3 },

    # Dates relative to Christmas are encoded as 10000 + 100*m + d
    # for simplicity.

    # Principal Feasts (precedence is 9)

    10106 => {name=>'Epiphany', prec=>9},
    11101 => {name=>'All Saints', prec=>9},
    11225 => {name=>'Christmas', prec=>9},

    # Days which can take priority over Sundays (precedence is 7)

    10101 => {name=>'Holy Name', prec=>7},
    10202 => {name=>'Presentation of our Lord', prec=>7},
    10806 => {name=>'Transfiguration', prec=>7},

    # (Precendence of Sundays is 5)

    # Days which cannot take priorities over Sundays (precedence is 4
    # if major, 3 otherwise)

    10110 => {name=>'William Laud', prec=>3},
    10113 => {name=>'Hilary', prec=>3},
    10117 => {name=>'Antony', prec=>3},
    10118 => {name=>'Confession of Saint Peter', prec=>4},
    10119 => {name=>'Wulfstan', prec=>3},
    10120 => {name=>'Fabian', prec=>3},
    10121 => {name=>'Agnes', prec=>3},
    10122 => {name=>'Vincent', martyr=>1, prec=>3},
    10123 => {name=>'Phillips Brooks', prec=>3},
    10125 => {name=>'Conversion of Saint Paul', prec=>4},
    10126 => {name=>'Timothy and Titus', prec=>3},
    10127 => {name=>'John Chrysostom', prec=>3},
    10128 => {name=>'Thomas Aquinas', prec=>3},

    10203 => {name=>'Anskar', prec=>3},
    10204 => {name=>'Cornelius', prec=>3},
    10205 => {name=>'Martyrs of Japan', martyr=>1, prec=>3},
    10213 => {name=>'Absalom Jones', prec=>3},
    10214 => {name=>'Cyril and Methodius', prec=>3},
    10215 => {name=>'Thomas Bray', prec=>3},
    10223 => {name=>'Polycarp', martyr=>1, prec=>3},
    10224 => {name=>'Matthias', prec=>4},
    10227 => {name=>'George Herbert', prec=>3},

    10301 => {name=>'David', prec=>3},
    10302 => {name=>'Chad', prec=>3},
    10303 => {name=>'John and Charles Wesley', prec=>3},
    10307 => {name=>'Perpetua and her companions', martyr=>1, prec=>3},
    10308 => {name=>'Gregory of Nyssa', prec=>3},
    10309 => {name=>'Gregory the Great', prec=>3},
    10317 => {name=>'Patrick', prec=>3},
    10318 => {name=>'Cyril', prec=>3},
    10319 => {name=>'Joseph', prec=>4},
    10320 => {name=>'Cuthbert', prec=>3},
    10321 => {name=>'Thomas Ken', prec=>3},
    10322 => {name=>'James De Koven', prec=>3},
    10323 => {name=>'Gregory the Illuminator', prec=>3},
    10325 => {name=>'Annunciation of our Lord', bvm=>1, prec=>4},
    10327 => {name=>'Charles Henry Brent', prec=>3},
    10329 => {name=>'John Keble', prec=>3},
    10331 => {name=>'John Donne', prec=>3},

    10401 => {name=>'Frederick Denison Maurice', prec=>3},
    10402 => {name=>'James Lloyd Breck', prec=>3},
    10403 => {name=>'Richard of Chichester', prec=>3},
    10408 => {name=>'William Augustus Muhlenberg', prec=>3},
    10409 => {name=>'William Law', prec=>3},
    10411 => {name=>'George Augustus Selwyn', prec=>3},
    10419 => {name=>'Alphege', martyr=>1, prec=>3},
    10421 => {name=>'Anselm', prec=>3},
    10425 => {name=>'Mark the Evangelist', prec=>4},
    10429 => {name=>'Catherine of Siena', prec=>3},

    10501 => {name=>'Philip and James', prec=>4},
    10502 => {name=>'Athanasius', prec=>3},
    10504 => {name=>'Monnica', prec=>3},
    10508 => {name=>'Julian of Norwich', prec=>3},
    10509 => {name=>'Gregory of Nazianzus', prec=>3},
    10519 => {name=>'Dustan', prec=>3},
    10520 => {name=>'Alcuin', prec=>3},
    10524 => {name=>'Jackson Kemper', prec=>3},
    10525 => {name=>'Bede', prec=>3},
    10526 => {name=>'Augustine of Canterbury', prec=>3},
    10531 => {name=>'Visitation of Mary', bvm=>1, prec=>4},

    10601 => {name=>'Justin', prec=>3},
    10602 => {name=>'Martyrs of Lyons', martyr=>1, prec=>3},
    10603 => {name=>'Martyrs of Uganda', martyr=>1, prec=>3},
    10605 => {name=>'Boniface', prec=>3},
    10609 => {name=>'Columba', prec=>3},
    10610 => {name=>'Ephrem of Edessa', prec=>3},
    10611 => {name=>'Barnabas', prec=>4},
    10614 => {name=>'Basil the Great', prec=>3},
    10616 => {name=>'Joseph Butler', prec=>3},
    10618 => {name=>'Bernard Mizeki', prec=>3},
    10622 => {name=>'Alban', martyr=>1, prec=>3},
    10624 => {name=>'Nativity of John the Baptist', prec=>3},
    10628 => {name=>'Irenaeus', prec=>3},
    10629 => {name=>'Peter and Paul', martyr=>1, prec=>3},
    10704 => {name=>'Independence Day', prec=>3},
    10711 => {name=>'Benedict of Nursia', prec=>3},
    10717 => {name=>'William White', prec=>3},
    10722 => {name=>'Mary Magdalene', prec=>4},
    10724 => {name=>'Thomas a Kempis', prec=>3},
    10725 => {name=>'James the Apostle', prec=>4},
    10726 => {name=>'Parents of the Blessed Virgin Mary', bvm=>1, prec=>3},
    10727 => {name=>'William Reed Huntington', prec=>3},
    10729 => {name=>'Mary and Martha', prec=>4},
    10730 => {name=>'William Wilberforce', prec=>3},
    10731 => {name=>'Joseph of Arimathaea', prec=>3},

    10806 => {name=>'Transfiguration', prec=>4},
    10807 => {name=>'John Mason Neale', prec=>3},
    10808 => {name=>'Dominic', prec=>3},
    10810 => {name=>'Lawrence', martyr=>1, prec=>3},
    10811 => {name=>'Clare', prec=>3},
    10813 => {name=>'Jeremy Taylor', prec=>3},
    10815 => {name=>'Mary the Virgin', bvm=>1, prec=>4},
    10818 => {name=>'William Porcher DuBose', prec=>3},
    10820 => {name=>'Bernard', prec=>3},
    10824 => {name=>'Bartholemew', prec=>4},
    10825 => {name=>'Louis', prec=>3},
    10828 => {name=>'Augustine of Hippo', prec=>3},
    10801 => {name=>'Aidan', prec=>3},

    10902 => {name=>'Martyrs of New Guinea', martyr=>1, prec=>3},
    10912 => {name=>'John Henry Hobart', prec=>3},
    10913 => {name=>'Cyprian', prec=>3},
    10914 => {name=>'Holy Cross', prec=>4},
    10916 => {name=>'Ninian', prec=>3},
    10918 => {name=>'Edward Bouverie Pusey', prec=>3},
    10919 => {name=>'Theodore of Tarsus', prec=>3},
    10920 => {name=>'John Coleridge Patteson and companions', martyr=>1, prec=>3},
    10921 => {name=>'Matthew', martyr=>1, prec=>4},
    10925 => {name=>'Sergius', prec=>3},
    10926 => {name=>'Lancelot Andrewes', prec=>3},
    10929 => {name=>'Michael and All Angels', prec=>4},
    10930 => {name=>'Jerome', prec=>3},

    11001 => {name=>'Remigius', prec=>3},
    11004 => {name=>'Francis of Assisi', prec=>3},
    11006 => {name=>'William Tyndale', prec=>3},
    11009 => {name=>'Robert Grosseteste', prec=>3},
    11015 => {name=>'Samuel Isaac Joseph Schereschewsky', prec=>3},
    11016 => {name=>'Hugh Latimer, Nicholas Ridley, Thomas Cranmer', martyr=>1, prec=>3},
    11017 => {name=>'Ignatius', martyr=>1, prec=>3},
    11018 => {name=>'Luke', prec=>4},
    11019 => {name=>'Henry Martyn', prec=>3},
    11023 => {name=>'James of Jerusalem', martyr=>1, prec=>4},
    11026 => {name=>'Alfred the Great', prec=>3},
    11028 => {name=>'Simon and Jude', prec=>4},
    11029 => {name=>'James Hannington and his companions', martyr=>1, prec=>3},

    11101 => {name=>'All Saints', prec=>4},
    11102 => {name=>'All Faithful Departed', prec=>3},
    11103 => {name=>'Richard Hooker', prec=>3},
    11107 => {name=>'Willibrord', prec=>3},
    11110 => {name=>'Leo the Great', prec=>3},
    11111 => {name=>'Martin of Tours', prec=>3},
    11112 => {name=>'Charles Simeon', prec=>3},
    11114 => {name=>'Consecration of Samuel Seabury', prec=>3},
    11116 => {name=>'Margaret', prec=>3},
    11117 => {name=>'Hugh', prec=>3},
    11118 => {name=>'Hilda', prec=>3},
    11119 => {name=>'Elizabeth of Hungary', prec=>3},
    11123 => {name=>'Clement of Rome', prec=>3},
    11130 => {name=>'Andrew', prec=>4},

    11201 => {name=>'Nicholas Ferrar', prec=>3},
    11202 => {name=>'Channing Moore Williams', prec=>3},
    11204 => {name=>'John of Damascus', prec=>3},
    11205 => {name=>'Clement of Alexandria', prec=>3},
    11206 => {name=>'Nicholas', prec=>3},
    11207 => {name=>'Ambrose', prec=>3},
    11221 => {name=>'Thomas', prec=>4},
    # Christmas is dealt with above
    11226 => {name=>'Stephen', martyr=>1, prec=>4},
    11227 => {name=>'John the Apostle', prec=>4},
    11228 => {name=>'Holy Innocents', martyr=>1, prec=>4},

];
