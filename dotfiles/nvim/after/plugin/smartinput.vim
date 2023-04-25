" Define rule for French quotation marks: « »
call smartinput#map_to_trigger('i', '«', '«', '«')
call smartinput#map_to_trigger('i', '»', '»', '»')
call smartinput#define_rule({'at': '\%#', 'char': '«', 'input': '«  »<Left><Left>'})
call smartinput#define_rule({'at': '\%#[\s ]*»', 'char': '»', 'input': '<C-r>=smartinput#_leave_block(''»'')<Enter><Right><Space>'})
call smartinput#define_rule({'at': '«[\s ]*\%#[\s ]*»', 'char': '<BS>', 'input': '<BS><Del>'})
call smartinput#define_rule({'at': '«[\s ]*»\%#', 'char': '<BS>', 'input': '<BS><BS>'})
