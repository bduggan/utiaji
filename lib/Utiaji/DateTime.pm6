unit class Utiaji::DateTime is DateTime;

enum days «:Mon(1) Tue Wed Thu Fri Sat Sun»;
enum months «:Jan(1) Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec»;
method new(|args) {
    self.DateTime::new(
        |args,
        :formatter( sub ($x) { sprintf("%s, %d %s %d %02d:%02d:%02d %s",
                $x.weekday, $x.day-of-month, $x.month-name, $x.year,
                $x.hour, $x.minute, $x.whole-second, $x.zone-name); })
    )
}
method weekday {
    return days(self.day-of-week);
}
method month-name {
    return months(self.month);
}
method zone-name {
    return self.offset-in-hours if self.offset-in-hours;
    return "GMT"
}
