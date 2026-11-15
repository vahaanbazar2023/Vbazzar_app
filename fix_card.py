with open('lib/features/auction/views/acution_vechile_listing.dart', 'r') as f:
    lines = f.readlines()

new = [
    '          // Start Price + Highest Bid - only when expanded\n',
    '          if (_expanded)\n',
    '            Padding(\n',
    '              padding: EdgeInsets.fromLTRB(10.w, 4.h, 10.w, 0),\n',
    '              child: Row(\n',
    '                children: [\n',
    '                  Expanded(\n',
    '                    child: _BidChip(\n',
    "                      label: 'Start Price',\n",
    "                      value: '\u20b9 \${_fmt(v.minimumPrice)}',\n",
    '                    ),\n',
    '                  ),\n',
    '                  SizedBox(width: 8.w),\n',
    '                  Expanded(\n',
    '                    child: _BidChip(\n',
    "                      label: 'Highest Bid',\n",
    '                      value: v.currentHighestBid != null &&\n',
    '                              v.currentHighestBid! > 0\n',
    "                          ? '\u20b9 \${_fmt(v.currentHighestBid!)}'\n",
    "                          : 'No bids',\n",
    '                    ),\n',
    '                  ),\n',
    '                ],\n',
    '              ),\n',
    '            ),\n',
]

result = lines[:559] + new + lines[588:]
with open('lib/features/auction/views/acution_vechile_listing.dart', 'w') as f:
    f.writelines(result)
print('Done')
