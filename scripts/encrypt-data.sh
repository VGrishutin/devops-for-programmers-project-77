SOURCE_DIR=$1
DEST_DIR=$2
VAULT_PW_FILE=$3

for file in $(ls $SOURCE_DIR -p | grep -v /)
do
  ansible-vault encrypt $SOURCE_DIR/$file --output $DEST_DIR/$file --vault-password-file $VAULT_PW_FILE
  echo "$file encrypted"
done