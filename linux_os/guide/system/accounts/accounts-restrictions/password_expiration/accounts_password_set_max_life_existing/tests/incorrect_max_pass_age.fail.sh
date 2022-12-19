#!/bin/bash

MAX_PAS_AGE=99999

useradd testuser_123

chage -M $MAX_PAS_AGE testuser_123
