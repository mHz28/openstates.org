# Generated by Django 2.2.10 on 2020-03-25 18:41

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ("legislative", "0012_billdocument_extras"),
    ]

    operations = [
        migrations.CreateModel(
            name="Bundle",
            fields=[
                (
                    "id",
                    models.AutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                ("slug", models.SlugField(unique=True)),
                ("name", models.CharField(max_length=100)),
            ],
        ),
        migrations.CreateModel(
            name="BundleBill",
            fields=[
                (
                    "id",
                    models.AutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                ("order", models.IntegerField(default=1)),
                (
                    "bill_id",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        to="legislative.Bill",
                    ),
                ),
                (
                    "bundle_id",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE, to="bundles.Bundle"
                    ),
                ),
            ],
            options={"unique_together": {("bundle_id", "bill_id")},},
        ),
        migrations.AddField(
            model_name="bundle",
            name="bills",
            field=models.ManyToManyField(
                through="bundles.BundleBill", to="legislative.Bill"
            ),
        ),
    ]
