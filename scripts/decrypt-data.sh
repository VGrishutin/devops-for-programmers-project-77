SOURCE_DIR=$1
VAULT_PW_FILE=$2

for file in $(ls $SOURCE_DIR -p | grep -v /)
do
  ansible-vault decrypt $SOURCE_DIR/$file --output ./terraform/$file --vault-password-file $VAULT_PW_FILE
  echo "$file decrypted"
done