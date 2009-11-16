rm index_spo
grep 'B get from index SPO:' app.log | cut -c 36- | sort | uniq >>index_spo
rm index_s
grep 'B get from index S:' app.log | cut -c 36- | sort | uniq >>index_s
rm index_p
grep 'B get from index P:' app.log | cut -c 36- | sort | uniq >>index_p
rm index_o
grep 'B get from index O:' app.log | cut -c 36- | sort | uniq >>index_o
rm index_sp
grep 'B get from index SP:' app.log | cut -c 36- | sort | uniq >>index_sp
rm index_po
grep 'B get from index PO:' app.log | cut -c 36- | sort | uniq >>index_po
rm index_op
grep 'B get from index OP:' app.log | cut -c 36- | sort | uniq >>index_op


