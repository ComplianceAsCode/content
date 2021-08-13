#!/bin/bash

sed -i '/:\(\*\|!!\):/!d' /etc/shadow
echo 'max-test-user:$1$q.YkdxU1$ADmXcU4xwPrM.Pc.dclK81:18648:1:90::::' >> /etc/shadow
