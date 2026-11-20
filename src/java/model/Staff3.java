package model;

/** Nhân viên. Librarian3 và Manager3 kế thừa lớp này. */
public class Staff3 extends Member3 {
    private String position;
    private float salary;

    public Staff3() {
        super();
    }

    public String getPosition() { return position; }
    public void setPosition(String position) { this.position = position; }

    public float getSalary() { return salary; }
    public void setSalary(float salary) { this.salary = salary; }
}
