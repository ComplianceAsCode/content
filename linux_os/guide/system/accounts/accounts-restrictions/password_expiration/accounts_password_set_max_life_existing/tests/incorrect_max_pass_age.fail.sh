#!/bin/bash
MAX_PASS_AGE=99999

useradd testuser_123

chage -M $MAX_PASS_AGE testuser_123
