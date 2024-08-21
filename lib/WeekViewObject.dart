class WeekViewObject {
  Week? week;

  WeekViewObject({this.week});

  WeekViewObject.fromJson(Map<String, dynamic> json) {
    week = json['week'] != null ? new Week.fromJson(json['week']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.week != null) {
      data['week'] = this.week!.toJson();
    }
    return data;
  }
}

class Week {
  WeekDay? monday;
  WeekDay? tuesday;
  WeekDay? wednesday;
  WeekDay? thursday;
  WeekDay? friday;

  Week({this.monday, this.tuesday, this.wednesday, this.thursday, this.friday});

  Week.fromJson(Map<String, dynamic> json) {
    monday =
        json['monday'] != null ? new WeekDay.fromJson(json['monday']) : null;
    tuesday =
        json['tuesday'] != null ? new WeekDay.fromJson(json['tuesday']) : null;
    wednesday = json['wednesday'] != null
        ? new WeekDay.fromJson(json['wednesday'])
        : null;
    thursday = json['thursday'] != null
        ? new WeekDay.fromJson(json['thursday'])
        : null;
    friday =
        json['friday'] != null ? new WeekDay.fromJson(json['friday']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.monday != null) {
      data['monday'] = this.monday!.toJson();
    }
    if (this.tuesday != null) {
      data['tuesday'] = this.tuesday!.toJson();
    }
    if (this.wednesday != null) {
      data['wednesday'] = this.wednesday!.toJson();
    }
    if (this.thursday != null) {
      data['thursday'] = this.thursday!.toJson();
    }
    if (this.friday != null) {
      data['friday'] = this.friday!.toJson();
    }
    return data;
  }
}

class WeekDay {
  Slots? slots;

  WeekDay({this.slots});

  WeekDay.fromJson(Map<String, dynamic> json) {
    slots = json['slots'] != null ? new Slots.fromJson(json['slots']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.slots != null) {
      data['slots'] = this.slots!.toJson();
    }
    return data;
  }
}

class Slots {
  Slot? slot8;
  Slot? slot9;
  Slot? slot10;
  Slot? slot11;
  Slot? slot12;
  Slot? slot13;
  Slot? slot14;
  Slot? slot15;
  Slot? slot16;
  Slot? slot17;
  Slot? slot18;
  Slot? slot19;

  Slots(
      {this.slot8,
      this.slot9,
      this.slot10,
      this.slot11,
      this.slot12,
      this.slot13,
      this.slot14,
      this.slot15,
      this.slot16,
      this.slot17,
      this.slot18,
      this.slot19});

  Slots.fromJson(Map<String, dynamic> json) {
    slot8 = json['slot_8'] != null ? new Slot.fromJson(json['slot_8']) : null;
    slot9 = json['slot_9'] != null ? new Slot.fromJson(json['slot_9']) : null;
    slot10 =
        json['slot_10'] != null ? new Slot.fromJson(json['slot_10']) : null;
    slot11 =
        json['slot_11'] != null ? new Slot.fromJson(json['slot_11']) : null;
    slot12 =
        json['slot_12'] != null ? new Slot.fromJson(json['slot_12']) : null;
    slot13 =
        json['slot_13'] != null ? new Slot.fromJson(json['slot_13']) : null;
    slot14 =
        json['slot_14'] != null ? new Slot.fromJson(json['slot_14']) : null;
    slot15 =
        json['slot_15'] != null ? new Slot.fromJson(json['slot_15']) : null;
    slot16 =
        json['slot_16'] != null ? new Slot.fromJson(json['slot_16']) : null;
    slot17 =
        json['slot_17'] != null ? new Slot.fromJson(json['slot_17']) : null;
    slot18 =
        json['slot_18'] != null ? new Slot.fromJson(json['slot_18']) : null;
    slot19 =
        json['slot_19'] != null ? new Slot.fromJson(json['slot_19']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.slot8 != null) {
      data['slot_8'] = this.slot8!.toJson();
    }
    if (this.slot9 != null) {
      data['slot_9'] = this.slot9!.toJson();
    }
    if (this.slot10 != null) {
      data['slot_10'] = this.slot10!.toJson();
    }
    if (this.slot11 != null) {
      data['slot_11'] = this.slot11!.toJson();
    }
    if (this.slot12 != null) {
      data['slot_12'] = this.slot12!.toJson();
    }
    if (this.slot13 != null) {
      data['slot_13'] = this.slot13!.toJson();
    }
    if (this.slot14 != null) {
      data['slot_14'] = this.slot14!.toJson();
    }
    if (this.slot15 != null) {
      data['slot_15'] = this.slot15!.toJson();
    }
    if (this.slot16 != null) {
      data['slot_16'] = this.slot16!.toJson();
    }
    if (this.slot17 != null) {
      data['slot_17'] = this.slot17!.toJson();
    }
    if (this.slot18 != null) {
      data['slot_18'] = this.slot18!.toJson();
    }
    if (this.slot19 != null) {
      data['slot_19'] = this.slot19!.toJson();
    }
    return data;
  }
}

class Slot {
  String? teacherName;
  String? roomNumber;
  String? className;
  String? classNameShort;
  String? classType;
  String? userComment;

  Slot(
      {this.teacherName,
      this.roomNumber,
      this.className,
      this.classNameShort,
      this.classType,
      this.userComment});

  Slot.fromJson(Map<String, dynamic> json) {
    teacherName = json['teacher_name'];
    roomNumber = json['room_number'];
    className = json['class_name'];
    classNameShort = json['class_name_short'];
    classType = json['class_type'];
    userComment = json['user_comment'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['teacher_name'] = this.teacherName;
    data['room_number'] = this.roomNumber;
    data['class_name'] = this.className;
    data['class_name_short'] = this.classNameShort;
    data['class_type'] = this.classType;
    data['user_comment'] = this.userComment;
    return data;
  }
}
