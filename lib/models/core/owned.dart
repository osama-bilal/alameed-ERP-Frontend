// class OwnedFields {
//   int? createdById;
//   int? updatedById;

//   // OwnedFields({this.createdById, this.updatedById});

//   Map<String, dynamic> ownedToMap() => {
//         'created_by': createdById,
//         'updated_by': updatedById,
//       };

//   void ownedFromMap(Map<String, dynamic> map) {
//     createdById = map['created_by'];
//     updatedById = map['updated_by'];
//   }
// }