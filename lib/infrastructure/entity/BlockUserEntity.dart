class BlockUserEntity {
  String name;

  String uid;

  String photoUrl;

  BlockUserEntity({this.uid, this.name, this.photoUrl});

  BlockUserEntity.fromJSON(Map json) {
    this.uid = json['uid'];
    this.name = json['name'];
    this.photoUrl = json['photo_url'];
  }

  Map<String, dynamic> toObject() {
    return <String, dynamic>{'uid': uid, 'name': name, 'photo_url': photoUrl};
  }
}

class BlockUserListEntity {
  List<BlockUserEntity> blockUsers;

  BlockUserListEntity({this.blockUsers});

  BlockUserListEntity.fromJSON(Map json) {
    this.blockUsers = json['block_users'] != null
        ? (json['block_users'] as List).map(
            (e) => e == null ? BlockUserEntity() : BlockUserEntity.fromJSON(e))
        : null;
  }
}
