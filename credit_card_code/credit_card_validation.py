import re

def validate_credit_card(card_number):
    # Checking for starting digits, length, group separation
    pattern = re.compile(r"^(4|5|6)\d{3}(-?\d{4}){3}$")
    if not pattern.match(card_number):
        return False

    # Checking for consecutive repeated digits
    consecutive_digits = re.compile(r"(\d)\1{3,}")
    if consecutive_digits.search(card_number.replace("-", "")):
        return False

    return True


print(validate_credit_card('4253625879615786'))
print(validate_credit_card('4424424424442444'))
print(validate_credit_card('5122-2368-7954-3214'))
print(validate_credit_card('42536258796157867'))
print(validate_credit_card('4424444424442444'))
print(validate_credit_card('5122-2368-7954 - 3214'))
print(validate_credit_card('44244x4424442444'))
print(validate_credit_card('0525362587961578'))